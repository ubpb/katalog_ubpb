lock "~> 3.9"

set :application, "katalog"
set :repo_url,    "git@github.com:ubpb/katalog.git"
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
set :rvm_ruby_version, IO.read(".ruby-version").strip

set :rails_env, "production"

namespace :app do
  namespace :maintenance do
    desc 'Activate maintenance mode'
    task :on do
      on roles(:web), in: :parallel do |host|
        within release_path do
          execute :touch, "public/MAINTENANCE_ON"
        end
      end
    end

    desc 'Deactivate maintenance mode'
    task :off do
      on roles(:web), in: :parallel do |host|
        within release_path do
          execute :rm, "public/MAINTENANCE_ON"
        end
      end
    end
  end
end
