set :repository, "git://github.com/zeyuLiang/MEIZU-ISSUES.git"
set :domain, "172.16.201.15"
set :application_servers, %w(172.16.201.15)
set :migration_server, "172.16.201.15"
set :user, "rails"
set :rails_env, "production"
set :branch, "redmine_production"
# set :deploy_via, :remote_cache
set :application, "plano"
#ssh_options[:port] = 16120 

load File.dirname(__FILE__) + "/shared_code"

task :assets_precompile, :roles => [:app] do
  run "cd #{release_path}; RAILS_ENV=#{rails_env} bundle exec rake assets:precompile 2>/dev/null"
end

#after "deploy:update_code", :assets_precompile
