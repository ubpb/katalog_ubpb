lock "~> 3.9"

set :application, "katalog"
set :repo_url,    "git@github.com:ubpb/katalog_ubpb.git"
set :branch,      "master"
set :log_level,   :debug

set :linked_files, fetch(:linked_files, []).push(
  "config/database.yml", "config/secrets.yml", "config/config.yml", "config/newrelic.yml"
)
set :linked_dirs, fetch(:linked_dirs, []).push(
  "log", "tmp/pids", "tmp/cache", "tmp/sockets", "vendor/bundle",
  "public/system"
)

set :rvm_type,         :user
set :rvm_ruby_version, "default"

set :rails_env, "production"
