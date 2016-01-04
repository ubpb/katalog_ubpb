source "https://rubygems.org"

gem "autoprefixer-rails",    "~> 6.0.3"
gem "bibtex-ruby",           "~> 4.0", require: "bibtex"
gem "bootstrap-sass",        "~> 3.3.5"
gem "browser",               "~> 0.8.0"
gem "cancancan",             "~> 1.12.0"
gem "coffee-rails",          "~> 4.1.0"
gem "dotenv-rails",          "~> 2.0.2"
gem "font-awesome-rails",    "~> 4.4.0.0"
gem "htmlentities",          "~> 4.3.4"
gem "i18n-backend-advanced", "~> 0.1.0"
gem "i18n-js",               ">= 3.0.0.rc11"
gem "jbuilder",              "~> 2.2"
gem "jquery-rails",          "~> 4.0.3"
gem "jquery-tablesorter",    "~> 1.19.1"
gem "jquery-turbolinks",     "~> 2.1.0"
gem "jquery-ui-rails",       "~> 5.0.3"
gem "libxml-ruby",           "~> 2.8", require: "libxml" # for ActiveSupport::XmlMini.backend = "LibXML"
gem "mysql2",                "~> 0.3.20" # ActiveRecord requires ~0.3.0 currently
#gem "opal-rails",            "~> 0.8"
gem "ox",                    "~> 2.2.2"
gem "rails",                 "= 4.2.5"
gem "rails-html-sanitizer",  "~> 1.0.1"
gem "rails-i18n",            "~> 4.0.6"
gem "roadie-rails",          "~> 1.0.2"
gem "sass-rails",            "~> 5.0.1"
gem "servizio",              "~> 0.6"
gem "simple_form",           "~> 3.1.0"
gem "slim",                  "~> 3.0.1"
gem "turbolinks",            "~> 2.5.2"
gem "uglifier",              "~> 2.5.3"
gem "uservoice-ruby",        "~> 0.0.11"

gem "skala", github: "ubpb/skala", branch: :master

# TODO: Move me to test after golive
gem "sqlite3", "~> 1.3"

#
# rails-assets.org
#
# Better use three component version numbers (~> x.y.z) because js assets often
# change structure/behaviour within minor version updates.
#
source "https://rails-assets.org" do
  gem "rails-assets-animate.css",                 "~> 3.4.0"
  # gem "rails-assets-flag-icon-css",               "~> 0.8.4"
  gem "rails-assets-imagesloaded",                "~> 3.2.0"
  gem "rails-assets-jaubourg--jquery-jsonp",      "~> 2.4.0"
  gem "rails-assets-lodash",                      "~> 3.0"
  gem "rails-assets-matchHeight",                 "~> 0.5"
  gem "rails-assets-ractive",                     "~> 0.7.3"
  gem "rails-assets-ractive-events-keys",         "~> 0.2.1"
  gem "rails-assets-relayfoods-jquery.sparkline", "~> 2.1.4"
  gem "rails-assets-urijs",                       "~> 1.16.1" # "~> 1.14.1"
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
  gem "pry",                "~> 0.10.3"
  gem "pry-byebug",         "~> 3.3.0"
  gem "pry-rails",          "~> 0.3.4"
  gem "pry-rescue",         "~> 1.4.2"
  gem "pry-state",          "~> 0.1.7"

  gem "puma",               "~> 2.9"
  gem "quiet_assets",       "~> 1.0"
  gem "rspec-rails",        "~> 3.0"
end

group :test do
  gem "capybara",                  "~> 2.4"
  gem "codeclimate-test-reporter", require: nil
  gem "database_cleaner",          "~> 1.3"
  gem "poltergeist",               "~> 1.5"
  gem "simplecov",                 "~> 0.9"
end

