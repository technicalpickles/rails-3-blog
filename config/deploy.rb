set :repository,  "."
set :deploy_via, :copy
set :scm, :none

set :user, 'ubuntu'

ssh_options[:keys] = ["#{ENV['HOME']}/.sumo/keypair.pem"]

set :instance, YAML.load_file(File.join(File.dirname(__FILE__), 'moonshine.yml'))[:domain]
server instance, :app, :web, :db, :primary => true
