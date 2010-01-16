require 'abstract_unit'

module AbstractController
  module Testing
  
    class ControllerWithCallbacks < AbstractController::Base
      include AbstractController::Callbacks
    end
    
    class Callback1 < ControllerWithCallbacks
      set_callback :process_action, :before, :first
      
      def first
        @text = "Hello world"
      end
      
      def index
        self.response_body = @text
      end
    end
    
    class TestCallbacks1 < ActiveSupport::TestCase
      test "basic callbacks work" do
        controller = Callback1.new
        result = controller.process(:index)
        assert_equal "Hello world", controller.response_body
      end
    end

    class Callback2 < ControllerWithCallbacks
      before_filter :first
      after_filter :second
      around_filter :aroundz
      
      def first
        @text = "Hello world"
      end
      
      def second
        @second = "Goodbye"
      end
      
      def aroundz
        @aroundz = "FIRST"
        yield
        @aroundz << "SECOND"
      end
      
      def index
        self.response_body = @text
      end      
    end
    
    class TestCallbacks2 < ActiveSupport::TestCase
      def setup
        @controller = Callback2.new
      end

      test "before_filter works" do
        result = @controller.process(:index)
        assert_equal "Hello world", @controller.response_body
      end
      
      test "after_filter works" do
        @controller.process(:index)
        assert_equal "Goodbye", @controller.instance_variable_get("@second")
      end
      
      test "around_filter works" do
        @controller.process(:index)
        assert_equal "FIRSTSECOND", @controller.instance_variable_get("@aroundz")
      end
    end
    
    class Callback3 < ControllerWithCallbacks
      before_filter do |c|
        c.instance_variable_set("@text", "Hello world")
      end
      
      after_filter do |c|
        c.instance_variable_set("@second", "Goodbye")
      end
            
      def index
        self.response_body = @text
      end
    end

    class TestCallbacks3 < ActiveSupport::TestCase
      def setup
        @controller = Callback3.new
      end
      
      test "before_filter works with procs" do
        result = @controller.process(:index)
        assert_equal "Hello world", @controller.response_body
      end
      
      test "after_filter works with procs" do
        result = @controller.process(:index)
        assert_equal "Goodbye", @controller.instance_variable_get("@second")
      end      
    end
    
    class CallbacksWithConditions < ControllerWithCallbacks
      before_filter :list, :only => :index
      before_filter :authenticate, :except => :index
      
      def index
        self.response_body = @list.join(", ")
      end
      
      def sekrit_data
        self.response_body = (@list + [@authenticated]).join(", ")
      end
      
      private
      def list
        @list = ["Hello", "World"]
      end
      
      def authenticate
        @list = []
        @authenticated = "true"
      end
    end
    
    class TestCallbacksWithConditions < ActiveSupport::TestCase
      def setup
        @controller = CallbacksWithConditions.new
      end

      test "when :only is specified, a before filter is triggered on that action" do
        @controller.process(:index)
        assert_equal "Hello, World", @controller.response_body
      end
      
      test "when :only is specified, a before filter is not triggered on other actions" do
        @controller.process(:sekrit_data)
        assert_equal "true", @controller.response_body
      end
      
      test "when :except is specified, an after filter is not triggered on that action" do
        result = @controller.process(:index)
        assert_nil @controller.instance_variable_get("@authenticated")
      end
    end
    
    class CallbacksWithArrayConditions < ControllerWithCallbacks
      before_filter :list, :only => [:index, :listy]
      before_filter :authenticate, :except => [:index, :listy]
      
      def index
        self.response_body = @list.join(", ")
      end
      
      def sekrit_data
        self.response_body = (@list + [@authenticated]).join(", ")
      end
      
      private
      def list
        @list = ["Hello", "World"]
      end
      
      def authenticate
        @list = []
        @authenticated = "true"
      end      
    end
    
    class TestCallbacksWithArrayConditions < ActiveSupport::TestCase
      def setup
        @controller = CallbacksWithArrayConditions.new
      end

      test "when :only is specified with an array, a before filter is triggered on that action" do
        result = @controller.process(:index)
        assert_equal "Hello, World", @controller.response_body
      end
      
      test "when :only is specified with an array, a before filter is not triggered on other actions" do
        result = @controller.process(:sekrit_data)
        assert_equal "true", @controller.response_body
      end
      
      test "when :except is specified with an array, an after filter is not triggered on that action" do
        result = @controller.process(:index)
        assert_nil @controller.instance_variable_get("@authenticated")
      end
    end    
    
    class ChangedConditions < Callback2
      before_filter :first, :only => :index
      
      def not_index
        self.response_body = @text.to_s
      end
    end
    
    class TestCallbacksWithChangedConditions < ActiveSupport::TestCase
      def setup
        @controller = ChangedConditions.new
      end
      
      test "when a callback is modified in a child with :only, it works for the :only action" do
        result = @controller.process(:index)
        assert_equal "Hello world", @controller.response_body
      end
      
      test "when a callback is modified in a child with :only, it does not work for other actions" do
        result = @controller.process(:not_index)
        assert_equal "", @controller.response_body
      end
    end
    
    class SetsResponseBody < ControllerWithCallbacks
      before_filter :set_body
      
      def index
        self.response_body = "Fail"
      end
      
      def set_body
        self.response_body = "Success"
      end
    end
    
    class TestHalting < ActiveSupport::TestCase
      test "when a callback sets the response body, the action should not be invoked" do
        controller = SetsResponseBody.new
        controller.process(:index)
        assert_equal "Success", controller.response_body
      end
    end
    
  end
end
