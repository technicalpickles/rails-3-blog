require 'rbconfig'

class MoonshineGenerator < Rails::Generators::Base
  argument :name, :optional => true, :default => 'application'

  def self.source_root
    @_moonshine_source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
  end
  

  def manifest
    directory 'app/manifests'
    directory 'config'
    
    intro = <<-INTRO
    
After the Moonshine generator finishes don't forget to:

- Edit config/moonshine.yml
Use this file to manage configuration related to deploying and running the app: 
domain name, git repos, package dependencies for gems, and more.

- Edit app/manifests/#{manifest_name}.rb
Use this to manage the configuration of everything else on the server:
define the server 'stack', cron jobs, mail aliases, configuration files 

    INTRO
    puts intro if File.basename($0) == 'generate'
  end

protected
  def manifest_name
    @manifest_name ||= name.downcase.underscore + "_manifest"
  end

  def klass_name
    @klass_name ||= manifest_name.classify
  end
end
