set :stages, %w(staging production redmine_production)
set :default_stage, "staging"
require 'capistrano/ext/multistage'
