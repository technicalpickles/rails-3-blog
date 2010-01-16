require 'fileutils'
require 'uri'
require 'set'

module ActionController #:nodoc:
  # Caching is a cheap way of speeding up slow applications by keeping the result of
  # calculations, renderings, and database calls around for subsequent requests.
  # Action Controller affords you three approaches in varying levels of granularity:
  # Page, Action, Fragment.
  #
  # You can read more about each approach and the sweeping assistance by clicking the
  # modules below.
  #
  # Note: To turn off all caching and sweeping, set
  #   config.action_controller.perform_caching = false.
  #
  # == Caching stores
  #
  # All the caching stores from ActiveSupport::Cache are available to be used as backends
  # for Action Controller caching. This setting only affects action and fragment caching
  # as page caching is always written to disk.
  #
  # Configuration examples (MemoryStore is the default):
  #
  #   config.action_controller.cache_store = :memory_store
  #   config.action_controller.cache_store = :file_store, "/path/to/cache/directory"
  #   config.action_controller.cache_store = :drb_store, "druby://localhost:9192"
  #   config.action_controller.cache_store = :mem_cache_store, "localhost"
  #   config.action_controller.cache_store = :mem_cache_store, Memcached::Rails.new("localhost:11211")
  #   config.action_controller.cache_store = MyOwnStore.new("parameter")
  module Caching
    extend ActiveSupport::Concern

    autoload :Actions, 'action_controller/caching/actions'
    autoload :Fragments, 'action_controller/caching/fragments'
    autoload :Pages, 'action_controller/caching/pages'
    autoload :Sweeper, 'action_controller/caching/sweeping'
    autoload :Sweeping, 'action_controller/caching/sweeping'

    included do
      @@cache_store = nil
      cattr_reader :cache_store

      # Defines the storage option for cached fragments
      def self.cache_store=(store_option)
        @@cache_store = ActiveSupport::Cache.lookup_store(store_option)
      end

      include Pages, Actions, Fragments
      include Sweeping if defined?(ActiveRecord)

      @@perform_caching = true
      cattr_accessor :perform_caching
    end

    module ClassMethods
      def cache_configured?
        perform_caching && cache_store
      end
    end

    def caching_allowed?
      request.get? && response.status == 200
    end

  protected
    # Convenience accessor
    def cache(key, options = {}, &block)
      if cache_configured?
        cache_store.fetch(ActiveSupport::Cache.expand_cache_key(key, :controller), options, &block)
      else
        yield
      end
    end

  private
    def cache_configured?
      self.class.cache_configured?
    end
  end
end
