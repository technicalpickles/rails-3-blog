require 'test/unit'
require 'rbconfig'
require 'active_support/core_ext/kernel/reporting'

class TestIsolated < Test::Unit::TestCase
  ruby = File.join(*RbConfig::CONFIG.values_at('bindir', 'RUBY_INSTALL_NAME'))

  Dir["#{File.dirname(__FILE__)}/**/*_test.rb"].each do |file|
    define_method("test #{file}") do
      command = "#{ruby} -Ilib:test #{file}"
      result = silence_stderr { `#{command}` }
      assert_block("#{command}\n#{result}") { $?.to_i.zero? }
    end
  end
end
