require "isolation/abstract_unit"

module BootTests
  class GemBooting < Test::Unit::TestCase
    include ActiveSupport::Testing::Isolation

    def setup
      # build_app
      # boot_rails
    end

    test "booting rails sets the load paths correctly" do
      # This test is pending reworking the boot process
    end
  end
end