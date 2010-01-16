require 'observer'

module ActiveRecord
  # Callbacks are hooks into the lifecycle of an Active Record object that allow you to trigger logic
  # before or after an alteration of the object state. This can be used to make sure that associated and
  # dependent objects are deleted when +destroy+ is called (by overwriting +before_destroy+) or to massage attributes
  # before they're validated (by overwriting +before_validation+). As an example of the callbacks initiated, consider
  # the <tt>Base#save</tt> call for a new record:
  #
  # * (-) <tt>save</tt>
  # * (-) <tt>valid</tt>
  # * (1) <tt>before_validation</tt>
  # * (-) <tt>validate</tt>
  # * (-) <tt>validate_on_create</tt>
  # * (2) <tt>after_validation</tt>
  # * (3) <tt>before_save</tt>
  # * (4) <tt>before_create</tt>
  # * (-) <tt>create</tt>
  # * (5) <tt>after_create</tt>
  # * (6) <tt>after_save</tt>
  #
  # That's a total of eight callbacks, which gives you immense power to react and prepare for each state in the
  # Active Record lifecycle. The sequence for calling <tt>Base#save</tt> for an existing record is similar, except that each
  # <tt>_on_create</tt> callback is replaced by the corresponding <tt>_on_update</tt> callback.
  #
  # Examples:
  #   class CreditCard < ActiveRecord::Base
  #     # Strip everything but digits, so the user can specify "555 234 34" or
  #     # "5552-3434" or both will mean "55523434"
  #     def before_validation_on_create
  #       self.number = number.gsub(/[^0-9]/, "") if attribute_present?("number")
  #     end
  #   end
  #
  #   class Subscription < ActiveRecord::Base
  #     before_create :record_signup
  #
  #     private
  #       def record_signup
  #         self.signed_up_on = Date.today
  #       end
  #   end
  #
  #   class Firm < ActiveRecord::Base
  #     # Destroys the associated clients and people when the firm is destroyed
  #     before_destroy { |record| Person.destroy_all "firm_id = #{record.id}"   }
  #     before_destroy { |record| Client.destroy_all "client_of = #{record.id}" }
  #   end
  #
  # == Inheritable callback queues
  #
  # Besides the overwritable callback methods, it's also possible to register callbacks through the use of the callback macros.
  # Their main advantage is that the macros add behavior into a callback queue that is kept intact down through an inheritance
  # hierarchy. Example:
  #
  #   class Topic < ActiveRecord::Base
  #     before_destroy :destroy_author
  #   end
  #
  #   class Reply < Topic
  #     before_destroy :destroy_readers
  #   end
  #
  # Now, when <tt>Topic#destroy</tt> is run only +destroy_author+ is called. When <tt>Reply#destroy</tt> is run, both +destroy_author+ and
  # +destroy_readers+ are called. Contrast this to the situation where we've implemented the save behavior through overwriteable
  # methods:
  #
  #   class Topic < ActiveRecord::Base
  #     def before_destroy() destroy_author end
  #   end
  #
  #   class Reply < Topic
  #     def before_destroy() destroy_readers end
  #   end
  #
  # In that case, <tt>Reply#destroy</tt> would only run +destroy_readers+ and _not_ +destroy_author+. So, use the callback macros when
  # you want to ensure that a certain callback is called for the entire hierarchy, and use the regular overwriteable methods
  # when you want to leave it up to each descendant to decide whether they want to call +super+ and trigger the inherited callbacks.
  #
  # *IMPORTANT:* In order for inheritance to work for the callback queues, you must specify the callbacks before specifying the
  # associations. Otherwise, you might trigger the loading of a child before the parent has registered the callbacks and they won't
  # be inherited.
  #
  # == Types of callbacks
  #
  # There are four types of callbacks accepted by the callback macros: Method references (symbol), callback objects,
  # inline methods (using a proc), and inline eval methods (using a string). Method references and callback objects are the
  # recommended approaches, inline methods using a proc are sometimes appropriate (such as for creating mix-ins), and inline
  # eval methods are deprecated.
  #
  # The method reference callbacks work by specifying a protected or private method available in the object, like this:
  #
  #   class Topic < ActiveRecord::Base
  #     before_destroy :delete_parents
  #
  #     private
  #       def delete_parents
  #         self.class.delete_all "parent_id = #{id}"
  #       end
  #   end
  #
  # The callback objects have methods named after the callback called with the record as the only parameter, such as:
  #
  #   class BankAccount < ActiveRecord::Base
  #     before_save      EncryptionWrapper.new
  #     after_save       EncryptionWrapper.new
  #     after_initialize EncryptionWrapper.new
  #   end
  #
  #   class EncryptionWrapper
  #     def before_save(record)
  #       record.credit_card_number = encrypt(record.credit_card_number)
  #     end
  #
  #     def after_save(record)
  #       record.credit_card_number = decrypt(record.credit_card_number)
  #     end
  #
  #     alias_method :after_find, :after_save
  #
  #     private
  #       def encrypt(value)
  #         # Secrecy is committed
  #       end
  #
  #       def decrypt(value)
  #         # Secrecy is unveiled
  #       end
  #   end
  #
  # So you specify the object you want messaged on a given callback. When that callback is triggered, the object has
  # a method by the name of the callback messaged. You can make these callbacks more flexible by passing in other
  # initialization data such as the name of the attribute to work with:
  #
  #   class BankAccount < ActiveRecord::Base
  #     before_save      EncryptionWrapper.new("credit_card_number")
  #     after_save       EncryptionWrapper.new("credit_card_number")
  #     after_initialize EncryptionWrapper.new("credit_card_number")
  #   end
  #
  #   class EncryptionWrapper
  #     def initialize(attribute)
  #       @attribute = attribute
  #     end
  #
  #     def before_save(record)
  #       record.send("#{@attribute}=", encrypt(record.send("#{@attribute}")))
  #     end
  #
  #     def after_save(record)
  #       record.send("#{@attribute}=", decrypt(record.send("#{@attribute}")))
  #     end
  #
  #     alias_method :after_find, :after_save
  #
  #     private
  #       def encrypt(value)
  #         # Secrecy is committed
  #       end
  #
  #       def decrypt(value)
  #         # Secrecy is unveiled
  #       end
  #   end
  #
  # The callback macros usually accept a symbol for the method they're supposed to run, but you can also pass a "method string",
  # which will then be evaluated within the binding of the callback. Example:
  #
  #   class Topic < ActiveRecord::Base
  #     before_destroy 'self.class.delete_all "parent_id = #{id}"'
  #   end
  #
  # Notice that single quotes (') are used so the <tt>#{id}</tt> part isn't evaluated until the callback is triggered. Also note that these
  # inline callbacks can be stacked just like the regular ones:
  #
  #   class Topic < ActiveRecord::Base
  #     before_destroy 'self.class.delete_all "parent_id = #{id}"',
  #                    'puts "Evaluated after parents are destroyed"'
  #   end
  #
  # == The +after_find+ and +after_initialize+ exceptions
  #
  # Because +after_find+ and +after_initialize+ are called for each object found and instantiated by a finder, such as <tt>Base.find(:all)</tt>, we've had
  # to implement a simple performance constraint (50% more speed on a simple test case). Unlike all the other callbacks, +after_find+ and
  # +after_initialize+ will only be run if an explicit implementation is defined (<tt>def after_find</tt>). In that case, all of the
  # callback types will be called.
  #
  # == <tt>before_validation*</tt> returning statements
  #
  # If the returning value of a +before_validation+ callback can be evaluated to +false+, the process will be aborted and <tt>Base#save</tt> will return +false+.
  # If Base#save! is called it will raise a ActiveRecord::RecordInvalid exception.
  # Nothing will be appended to the errors object.
  #
  # == Canceling callbacks
  #
  # If a <tt>before_*</tt> callback returns +false+, all the later callbacks and the associated action are cancelled. If an <tt>after_*</tt> callback returns
  # +false+, all the later callbacks are cancelled. Callbacks are generally run in the order they are defined, with the exception of callbacks
  # defined as methods on the model, which are called last.
  #
  # == Transactions
  #
  # The entire callback chain of a +save+, <tt>save!</tt>, or +destroy+ call runs
  # within a transaction. That includes <tt>after_*</tt> hooks. If everything
  # goes fine a COMMIT is executed once the chain has been completed.
  #
  # If a <tt>before_*</tt> callback cancels the action a ROLLBACK is issued. You
  # can also trigger a ROLLBACK raising an exception in any of the callbacks,
  # including <tt>after_*</tt> hooks. Note, however, that in that case the client
  # needs to be aware of it because an ordinary +save+ will raise such exception
  # instead of quietly returning +false+.
  module Callbacks
    extend ActiveSupport::Concern
    include ActiveSupport::Callbacks

    CALLBACKS = [
      :after_initialize, :after_find, :before_validation, :after_validation,
      :before_save, :around_save, :after_save, :before_create, :around_create,
      :after_create, :before_update, :around_update, :after_update,
      :before_destroy, :around_destroy, :after_destroy
    ]

    included do
      [:create_or_update, :valid?, :create, :update, :destroy].each do |method|
        alias_method_chain method, :callbacks
      end

      define_callbacks :initialize, :find, :save, :create, :update, :destroy,
                       :validation, :terminator => "result == false", :scope => [:kind, :name]
    end

    module ClassMethods
      def after_initialize(*args, &block)
        options = args.extract_options!
        options[:prepend] = true
        set_callback(:initialize, :after, *(args << options), &block)
      end

      def after_find(*args, &block)
        options = args.extract_options!
        options[:prepend] = true
        set_callback(:find, :after, *(args << options), &block)
      end

      [:save, :create, :update, :destroy].each do |callback|
        module_eval <<-CALLBACKS, __FILE__, __LINE__
          def before_#{callback}(*args, &block)
            set_callback(:#{callback}, :before, *args, &block)
          end

          def around_#{callback}(*args, &block)
            set_callback(:#{callback}, :around, *args, &block)
          end

          def after_#{callback}(*args, &block)
            options = args.extract_options!
            options[:prepend] = true
            options[:if] = Array(options[:if]) << "!halted && value != false"
            set_callback(:#{callback}, :after, *(args << options), &block)
          end
        CALLBACKS
      end

      def before_validation(*args, &block)
        options = args.extract_options!
        if options[:on]
          options[:if] = Array(options[:if])
          options[:if] << "@_on_validate == :#{options[:on]}"
        end
        set_callback(:validation, :before, *(args << options), &block)
      end

      def after_validation(*args, &block)
        options = args.extract_options!
        options[:if] = Array(options[:if])
        options[:if] << "!halted"
        options[:if] << "@_on_validate == :#{options[:on]}" if options[:on]
        options[:prepend] = true
        set_callback(:validation, :after, *(args << options), &block)
      end

      def method_added(meth)
        super
        if CALLBACKS.include?(meth.to_sym)
          ActiveSupport::Deprecation.warn("Base##{meth} has been deprecated, please use Base.#{meth} :method instead", caller[0,1])
          send(meth.to_sym, meth.to_sym)
        end
      end
    end

    def create_or_update_with_callbacks #:nodoc:
      _run_save_callbacks do
        create_or_update_without_callbacks
      end
    end
    private :create_or_update_with_callbacks

    def create_with_callbacks #:nodoc:
      _run_create_callbacks do
        create_without_callbacks
      end
    end
    private :create_with_callbacks

    def update_with_callbacks(*args) #:nodoc:
      _run_update_callbacks do
        update_without_callbacks(*args)
      end
    end
    private :update_with_callbacks

    def valid_with_callbacks? #:nodoc:
      @_on_validate = new_record? ? :create : :update
      _run_validation_callbacks do
        valid_without_callbacks?
      end
    end

    def destroy_with_callbacks #:nodoc:
      _run_destroy_callbacks do
        destroy_without_callbacks
      end
    end

    def deprecated_callback_method(symbol) #:nodoc:
      if respond_to?(symbol)
        ActiveSupport::Deprecation.warn("Base##{symbol} has been deprecated, please use Base.#{symbol} :method instead")
        send(symbol)
      end
    end
  end
end
