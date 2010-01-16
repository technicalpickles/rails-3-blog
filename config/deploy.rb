set :repository,  "."
set :deploy_via, :copy
set :scm, :none

set :user, 'ubuntu'

ssh_options[:keys] = ["#{ENV['HOME']}/.sumo/keypair.pem"]

set :instance, YAML.load_file(File.join(File.dirname(__FILE__), 'moonshine.yml'))[:domain]
server instance, :app, :web, :db, :primary => true

namespace :gems do
  task :bundle, :roles => :app do
    run "cd #{release_path} && gem bundle --cached"
  end
end

after 'deploy:update_code', 'gems:bundle'

