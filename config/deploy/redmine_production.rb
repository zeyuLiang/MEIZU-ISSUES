set :repository, "git://github.com/zeyuLiang/MEIZU-ISSUES.git"
set :domain, "new_issues"
set :application_servers, %w(new_issues)
set :migration_server, "new_issues"
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
