source "https://rubygems.org"

gem "rails",                 "= 4.2.4"
gem "sqlite3",               "~> 1.3.9"
gem "cancancan",             "~> 1.12.0"
gem "bootstrap-sass",        "~> 3.3.5"
gem "browser",               "~> 0.8.0"
gem "coffee-rails",          "~> 4.1.0"
gem "font-awesome-rails",    "~> 4.4.0.0"
gem "jbuilder",              "~> 2.2"
gem "jquery-rails",          "~> 4.0.3"
gem "jquery-turbolinks",     "~> 2.1.0"
gem "jquery-ui-rails",       "~> 5.0.3"
gem "rails-html-sanitizer",  "~> 1.0.1"
gem "roadie-rails",          "~> 1.0.2"
gem "sass-rails",            "~> 5.0.1"
gem "simple_form",           "~> 3.1.0"
gem "slim",                  "~> 3.0.1"
gem "turbolinks",            "~> 2.5.2"
gem "uglifier",              "~> 2.5.3"
gem "uservoice-ruby",        "~> 0.0.11"
gem "jquery-tablesorter",    "~> 1.12.8"
gem "autoprefixer-rails",    "~> 6.0.3"
gem "dotenv-rails"
gem "rails-i18n"
gem "i18n-js", ">= 3.0.0.rc11"

gem "skala", github: "ubpb/skala", branch: :master

#
# rails-assets.org
#
source "https://rails-assets.org" do
  gem "rails-assets-imagesloaded",  "~> 3.1"
  gem "rails-assets-lodash",        "~> 3.0"
  gem "rails-assets-matchHeight",   "~> 0.5"
end

group :production do
  gem "newrelic_rpm", ">= 3.9"
end

group :development do
  gem "capistrano",           "~> 3.4.0"
  gem "capistrano-bundler",   "~> 1.1.4"
  gem "capistrano-rails",     "~> 1.1.2"
  gem "capistrano-rvm",       "~> 0.1.2"
  gem "letter_opener",        "~> 1.2.0"
end

group :development, :test do
  gem "pry",                "~> 0.9.12.6"
  gem "pry-byebug",         "<= 1.3.2"
  gem "pry-rails",          "~> 0.3.2"
  gem "pry-rescue",         "~> 1.4.1"
  gem "pry-stack_explorer", "~> 0.4.9.1"
  gem "pry-syntax-hacks",   "~> 0.0.6"
  gem "puma",               "~> 2.9.0"
  gem "quiet_assets",       "~> 1.0.3"
  gem "rspec-rails",        "~> 3.1.0"
end

group :test do
  gem "capybara",                  "~> 2.4.4"
  gem "codeclimate-test-reporter", "~> 0.4.5", require: nil
  gem "database_cleaner",          "~> 1.3.0"
  gem "poltergeist",               "~> 1.5.1"
  gem "simplecov",                 "~> 0.9.1"
end

