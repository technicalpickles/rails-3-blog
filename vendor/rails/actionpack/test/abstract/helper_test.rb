require 'abstract_unit'

ActionController::Base.helpers_dir = File.dirname(__FILE__) + '/../fixtures/helpers'

module AbstractController
  module Testing
  
    class ControllerWithHelpers < AbstractController::Base
      include AbstractController::RenderingController
      include Helpers

      def with_module
        render :inline => "Module <%= included_method %>"
      end
    end
   
    module HelperyTest
      def included_method
        "Included"
      end
    end
   
    class AbstractHelpers < ControllerWithHelpers
      helper(HelperyTest) do
        def helpery_test
          "World"
        end
      end

      helper :abc

      def with_block
        render :inline => "Hello <%= helpery_test %>"
      end

      def with_symbol
        render :inline => "I respond to bare_a: <%= respond_to?(:bare_a) %>"
      end
    end

    class AbstractHelpersBlock < ControllerWithHelpers
      helper do
        include ::AbstractController::Testing::HelperyTest
      end
    end

    class TestHelpers < ActiveSupport::TestCase

      def setup
        @controller = AbstractHelpers.new
      end

      def test_helpers_with_block
        @controller.process(:with_block)
        assert_equal "Hello World", @controller.response_body
      end

      def test_helpers_with_module
        @controller.process(:with_module)
        assert_equal "Module Included", @controller.response_body
      end

      def test_helpers_with_symbol
        @controller.process(:with_symbol)
        assert_equal "I respond to bare_a: true", @controller.response_body
      end

      def test_declare_missing_helper
        assert_raise(MissingSourceFile) { AbstractHelpers.helper :missing }
      end

      def test_helpers_with_module_through_block
        @controller = AbstractHelpersBlock.new
        @controller.process(:with_module)
        assert_equal "Module Included", @controller.response_body
      end

    end
    
  end
end
