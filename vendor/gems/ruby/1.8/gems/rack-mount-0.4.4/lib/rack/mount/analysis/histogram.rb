module Rack::Mount
  module Analysis
    class Histogram < Hash #:nodoc:
      attr_reader :count

      def initialize
        @count = 0
        super(0)
        expire_caches!
      end

      def <<(value)
        @count += 1
        self[value] += 1 if value
        expire_caches!
        self
      end

      def sorted_by_frequency
        sort_by { |_, value| value }.reverse!
      end

      def max
        @max ||= values.max || 0
      end

      def min
        @min ||= values.min || 0
      end

      def mid_range
        @mid_range ||= calculate_mid_range
      end

      def mean
        @mean ||= calculate_mean
      end

      def keys_above_mean
        @keys_above_mean ||= compute_keys_above_mean
      end

      private
        def calculate_mid_range
          (max + min) / 2
        end

        def calculate_mean
          count / size
        end

        def compute_keys_above_mean
          sorted_by_frequency.select { |_, value| value >= mean }.map! { |key, _| key }
        end

        def expire_caches!
          @max = @min = @mid_range = @mean = @keys_above_mean = nil
        end
    end
  end
end
