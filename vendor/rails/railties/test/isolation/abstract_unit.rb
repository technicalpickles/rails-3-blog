# Note:
# It is important to keep this file as light as possible
# the goal for tests that require this is to test booting up
# rails from an empty state, so anything added here could
# hide potential failures
#
# It is also good to know what is the bare minimum to get
# Rails booted up.
require 'fileutils'

# TODO: Remove rubygems when possible
require 'rubygems'
require 'test/unit'

# TODO: Remove setting this magic constant
RAILS_FRAMEWORK_ROOT = File.expand_path("#{File.dirname(__FILE__)}/../../..")

# These files do not require any others and are needed
# to run the tests
require "#{RAILS_FRAMEWORK_ROOT}/activesupport/lib/active_support/testing/isolation"
require "#{RAILS_FRAMEWORK_ROOT}/activesupport/lib/active_support/testing/declarative"

module TestHelpers
  module Paths
    module_function

    TMP_PATH = File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. tmp]))

    def tmp_path(*args)
      File.join(TMP_PATH, *args)
    end

    def app_path(*args)
      tmp_path(*%w[app] + args)
    end

    def framework_path
      RAILS_FRAMEWORK_ROOT
    end

    def rails_root
      app_path
    end
  end

  module Rack
    def extract_body(response)
      "".tap do |body|
        response[2].each {|chunk| body << chunk }
      end
    end

    def get(path)
      @app.call(::Rack::MockRequest.env_for(path))
    end

    def assert_welcome(resp)
      assert_equal 200, resp[0]
      assert resp[1]["Content-Type"] = "text/html"
      assert extract_body(resp).match(/Welcome aboard/)
    end

    def assert_success(resp)
      assert_equal 202, resp[0]
    end

    def assert_missing(resp)
      assert_equal 404, resp[0]
    end

    def assert_header(key, value, resp)
      assert_equal value, resp[1][key.to_s]
    end

    def assert_body(expected, resp)
      assert_equal expected, extract_body(resp)
    end
  end

  module Generation
    def build_app(options = {})
      FileUtils.rm_rf(app_path)
      FileUtils.cp_r(tmp_path('app_template'), app_path)

      # Delete the initializers unless requested
      unless options[:initializers]
        Dir["#{app_path}/config/initializers/*.rb"].each do |initializer|
          File.delete(initializer)
        end
      end

      add_to_config 'config.action_controller.session = { :key => "_myapp_session", :secret => "bac838a849c1d5c4de2e6a50af826079" }'
    end

    class Bukkit
      def initialize(path)
        @path = path
      end

      def write(file, string)
        path = "#{@path}/#{file}"
        FileUtils.mkdir_p(File.dirname(path))
        File.open(path, "w") {|f| f.puts string }
      end

      def delete(file)
        File.delete("#{@path}/#{file}")
      end
    end

    def plugin(name, string = "")
      dir = "#{app_path}/vendor/plugins/#{name}"
      FileUtils.mkdir_p(dir)
      File.open("#{dir}/init.rb", 'w') do |f|
        f.puts "::#{name.upcase} = 'loaded'"
        f.puts string
      end
      Bukkit.new(dir).tap do |bukkit|
        yield bukkit if block_given?
      end
    end

    def script(script)
      Dir.chdir(app_path) do
        `#{Gem.ruby} #{app_path}/script/#{script}`
      end
    end

    def add_to_config(str)
      environment = File.read("#{app_path}/config/application.rb")
      if environment =~ /(\n\s*end\s*)\Z/
        File.open("#{app_path}/config/application.rb", 'w') do |f|
          f.puts $` + "\n#{str}\n" + $1
        end
      end
    end

    def app_file(path, contents)
      FileUtils.mkdir_p File.dirname("#{app_path}/#{path}")
      File.open("#{app_path}/#{path}", 'w') do |f|
        f.puts contents
      end
    end

    def controller(name, contents)
      app_file("app/controllers/#{name}_controller.rb", contents)
    end

    def boot_rails
      root = File.expand_path('../../../..', __FILE__)
      begin
        require "#{root}/vendor/gems/environment"
      rescue LoadError
        %w(
          actionmailer/lib
          actionpack/lib
          activemodel/lib
          activerecord/lib
          activeresource/lib
          activesupport/lib
          railties/lib
          railties
        ).reverse_each do |path|
          $:.unshift "#{root}/#{path}"
        end
      end
    end
  end
end

class Test::Unit::TestCase
  include TestHelpers::Paths
  include TestHelpers::Rack
  include TestHelpers::Generation
  extend  ActiveSupport::Testing::Declarative
end

# Create a scope and build a fixture rails app
Module.new do
  extend TestHelpers::Paths
  # Build a rails app
  if File.exist?(tmp_path)
    FileUtils.rm_rf(tmp_path)
  end
  FileUtils.mkdir(tmp_path)

  environment = File.expand_path('../../../../vendor/gems/environment', __FILE__)
  if File.exist?("#{environment}.rb")
    require_environment = "-r #{environment}"
  end

  `#{Gem.ruby} #{require_environment} #{RAILS_FRAMEWORK_ROOT}/railties/bin/rails #{tmp_path('app_template')}`
  File.open("#{tmp_path}/app_template/config/boot.rb", 'w') do |f|
    f.puts "require '#{environment}'" if require_environment
    f.puts "require 'rails'"
  end
end
