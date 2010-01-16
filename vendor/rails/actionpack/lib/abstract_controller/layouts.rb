module AbstractController
  module Layouts
    extend ActiveSupport::Concern

    include RenderingController

    included do
      extlib_inheritable_accessor(:_layout_conditions) { Hash.new }
      extlib_inheritable_accessor(:_action_has_layout) { Hash.new }
      _write_layout_method
    end

    module ClassMethods
      def inherited(klass)
        super
        klass.class_eval do
          _write_layout_method
          @found_layouts = {}
        end
      end

      def clear_template_caches!
        @found_layouts.clear if @found_layouts
        super
      end

      def cache_layout(details)
        layout = @found_layouts
        key = Thread.current[:format_locale_key]

        # Cache nil
        if layout.key?(key)
          return layout[key]
        else
          layout[key] = yield
        end
      end

      # This module is mixed in if layout conditions are provided. This means
      # that if no layout conditions are used, this method is not used
      module LayoutConditions
        # Determines whether the current action has a layout by checking the
        # action name against the :only and :except conditions set on the
        # layout.
        #
        # ==== Returns
        # Boolean:: True if the action has a layout, false otherwise.
        def _action_has_layout?
          conditions = _layout_conditions

          if only = conditions[:only]
            only.include?(action_name)
          elsif except = conditions[:except]
            !except.include?(action_name)
          else
            true
          end
        end
      end

      # Specify the layout to use for this class.
      #
      # If the specified layout is a:
      # String:: the String is the template name
      # Symbol:: call the method specified by the symbol, which will return
      #   the template name
      # false::  There is no layout
      # true::   raise an ArgumentError
      #
      # ==== Parameters
      # layout<String, Symbol, false)>:: The layout to use.
      #
      # ==== Options (conditions)
      # :only<#to_s, Array[#to_s]>:: A list of actions to apply this layout to.
      # :except<#to_s, Array[#to_s]>:: Apply this layout to all actions but this one
      def layout(layout, conditions = {})
        include LayoutConditions unless conditions.empty?

        conditions.each {|k, v| conditions[k] = Array(v).map {|a| a.to_s} }
        self._layout_conditions = conditions

        @_layout = layout || false # Converts nil to false
        _write_layout_method
      end

      # If no layout is supplied, look for a template named the return
      # value of this method.
      #
      # ==== Returns
      # String:: A template name
      def _implied_layout_name
        name && name.underscore
      end

      # Takes the specified layout and creates a _layout method to be called
      # by _default_layout
      #
      # If there is no explicit layout specified:
      # If a layout is found in the view paths with the controller's
      # name, return that string. Otherwise, use the superclass'
      # layout (which might also be implied)
      def _write_layout_method
        case defined?(@_layout) ? @_layout : nil
        when String
          self.class_eval %{def _layout(details) #{@_layout.inspect} end}
        when Symbol
          self.class_eval <<-ruby_eval, __FILE__, __LINE__ + 1
            def _layout(details)
              #{@_layout}.tap do |layout|
                unless layout.is_a?(String) || !layout
                  raise ArgumentError, "Your layout method :#{@_layout} returned \#{layout}. It " \
                    "should have returned a String, false, or nil"
                end
              end
            end
          ruby_eval
        when false
          self.class_eval %{def _layout(details) end}
        when true
          raise ArgumentError, "Layouts must be specified as a String, Symbol, false, or nil"
        when nil
          if name
            self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
              def _layout(details)
                self.class.cache_layout(details) do
                  if template_exists?("#{_implied_layout_name}", details, :_prefix => "layouts")
                    "#{_implied_layout_name}"
                  else
                    super
                  end
                end
              end
            RUBY
          end
        end
        self.class_eval { private :_layout }
      end
    end

    def render_to_body(options = {})
      # In the case of a partial with a layout, handle the layout
      # here, and make sure the view does not try to handle it
      layout = options.delete(:layout) if options.key?(:partial)

      response = super

      # This is a little bit messy. We need to explicitly handle partial
      # layouts here since the core lookup logic is in the view, but
      # we need to determine the layout based on the controller
      #
      # TODO: An easier way to handle this would probably be to override
      # render_template
      if layout
        layout = _layout_for_option(layout, options[:_template].details)
        response = layout.render(view_context, options[:locals] || {}) { response }
      end

      response
    end

  private

    # This will be overwritten by _write_layout_method
    def _layout(details) end

    # Determine the layout for a given name and details.
    #
    # ==== Parameters
    # name<String>:: The name of the template
    # details<Hash{Symbol => Object}>:: A list of details to restrict
    #   the lookup to. By default, layout lookup is limited to the
    #   formats specified for the current request.
    def _layout_for_name(name, details)
      name && _find_layout(name, details)
    end

    # Determine the layout for a given name and details, taking into account
    # the name type.
    #
    # ==== Parameters
    # name<String|TrueClass|FalseClass|Symbol>:: The name of the template
    # details<Hash{Symbol => Object}>:: A list of details to restrict
    #   the lookup to. By default, layout lookup is limited to the
    #   formats specified for the current request.
    def _layout_for_option(name, details)
      case name
      when String     then _layout_for_name(name, details)
      when true       then _default_layout(details, true)
      when :default   then _default_layout(details, false)
      when false, nil then nil
      else
        raise ArgumentError,
          "String, true, or false, expected for `layout'; you passed #{name.inspect}"
      end
    end

    def _determine_template(options)
      super

      return unless (options.keys & [:text, :inline, :partial]).empty? || options.key?(:layout)
      layout = options.key?(:layout) ? options[:layout] : :default
      options[:_layout] = _layout_for_option(layout, options[:_template].details)
    end

    # Take in the name and details and find a Template.
    #
    # ==== Parameters
    # name<String>:: The name of the template to retrieve
    # details<Hash>:: A list of details to restrict the search by. This
    #   might include details like the format or locale of the template.
    #
    # ==== Returns
    # Template:: A template object matching the name and details
    def _find_layout(name, details)
      # TODO: Make prefix actually part of details in ViewPath#find_by_parts
      prefix = details.key?(:prefix) ? details.delete(:prefix) : "layouts"
      find_template(name, details, :_prefix => prefix)
    end

    # Returns the default layout for this controller and a given set of details.
    # Optionally raises an exception if the layout could not be found.
    #
    # ==== Parameters
    # details<Hash>:: A list of details to restrict the search by. This
    #   might include details like the format or locale of the template.
    # require_layout<Boolean>:: If this is true, raise an ArgumentError
    #   with details about the fact that the exception could not be
    #   found (defaults to false)
    #
    # ==== Returns
    # Template:: The template object for the default layout (or nil)
    def _default_layout(details, require_layout = false)
      if require_layout && _action_has_layout? && !_layout(details)
        raise ArgumentError,
          "There was no default layout for #{self.class} in #{view_paths.inspect}"
      end

      begin
        _layout_for_name(_layout(details), details) if _action_has_layout?
      rescue NameError => e
        raise NoMethodError,
          "You specified #{@_layout.inspect} as the layout, but no such method was found"
      end
    end

    def _action_has_layout?
      true
    end
  end
end
