ssh_options[:keys] = ["#{ENV['HOME']}/.sumo/keypair.pem"]

moonshine_config = YAML.load_file(File.join(ENV['RAILS_ROOT'] || Dir.pwd, 'config', 'moonshine.yml'))
set :instance, moonshine_config[:domain] || moonshine_config['domain']
server instance, :app, :web, :db, :primary => true

namespace :sumo do
  task :launch do
    `sumo launch`
  end

  task :terminate do
    `sumo terminate`
  end
end
