require "isolation/abstract_unit"

module InitializerTests
  class PathsTest < Test::Unit::TestCase
    include ActiveSupport::Testing::Isolation

    def setup
      build_app
      boot_rails
      require "rails"
    end

    test "rails does not initialize with ruby version 1.8.1" do
      assert_rails_does_not_boot "1.8.1"
    end

    test "rails does not initialize with ruby version 1.8.2" do
      assert_rails_does_not_boot "1.8.2"
    end

    test "rails does not initialize with ruby version 1.8.3" do
      assert_rails_does_not_boot "1.8.3"
    end

    test "rails does not initialize with ruby version 1.8.4" do
      assert_rails_does_not_boot "1.8.4"
    end

    test "rails does not initializes with ruby version 1.8.5" do
      assert_rails_does_not_boot "1.8.5"
    end

    test "rails does not initialize with ruby version 1.8.6" do
      assert_rails_does_not_boot "1.8.6"
    end

    test "rails initializes with ruby version 1.8.7" do
      assert_rails_boots "1.8.7"
    end

    test "rails initializes with the current version of Ruby" do
      assert_rails_boots
    end

    def set_ruby_version(version)
      $-w = nil
      Object.const_set(:RUBY_VERSION, version.freeze)
    end

    def assert_rails_boots(version = nil)
      set_ruby_version(version) if version
      assert_nothing_raised "It appears that rails does not boot" do
        Rails::Initializer.run { |c| c.frameworks = [] }
        Rails.initialize!
      end
    end

    def assert_rails_does_not_boot(version)
      set_ruby_version(version)
      $stderr = File.open("/dev/null", "w")
      assert_raises(SystemExit) do
        Rails::Initializer.run { |c| c.frameworks = [] }
        Rails.initialize!
      end
    end
  end
end
