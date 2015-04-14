lock "3.4.0"

set :application, "katalog"
set :repo_url,    "git@github.com:ubpb/katalog_ubpb.git"
set :branch,      "master"
set :log_level,   :debug

set :linked_files, fetch(:linked_files, []).push(
  "config/database.yml", "config/secrets.yml", "config/katalog.yml"
)
set :linked_dirs, fetch(:linked_dirs, []).push(
  "log", "tmp/pids", "tmp/cache", "tmp/sockets", "vendor/bundle",
  "public/system", "config/scopes"
)

set :rvm_type,         :user
set :rvm_ruby_version, "2.2.1"

set :rails_env, "production"

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, "cache:clear"
      # end
    end
  end

end
