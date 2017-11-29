source "https://rubygems.org"

gem "autoprefixer-rails",    "~> 6.4.1"
gem "bibtex-ruby",           "~> 4.4.2", require: "bibtex"
gem "bootstrap-sass",        "~> 3.3.7"
gem "browser",               "~> 2.2.0"
gem "cancancan",             "~> 1.15"
gem "coffee-rails",          "~> 4.2.1"
gem "dotenv-rails",          "~> 2.1.1"
gem "font-awesome-rails",    "~> 4.6.3"
gem "htmlentities",          "~> 4.3.4"
gem "i18n-backend-advanced", "~> 0.1.3"
gem "i18n-js",               ">= 3.0.0.rc13"
gem "jbuilder",              "~> 2.6"
gem "jquery-rails",          "~> 4.1.1"
gem "jquery-tablesorter",    "~> 1.21"
gem "jquery-turbolinks",     "~> 2.1.0"
gem "jquery-ui-rails",       "~> 5.0.5"
gem "libxml-ruby",           "~> 2.9", require: "libxml" # for ActiveSupport::XmlMini.backend = "LibXML"
gem "mysql2",                "~> 0.4.4"
gem "ox",                    "~> 2.8.1"
gem "rails",                 "~> 5.0.0"
gem "rails-html-sanitizer",  "~> 1.0.3"
gem "rails-i18n",            "~> 5.0.0"
gem "rinku",                 "~> 2.0.0"
gem "roadie-rails",          "~> 1.1.1"
gem "sass-rails",            "~> 5.0.6"
gem "servizio",              "~> 0.6"
gem "simple_form",           "~> 3.2.1"
gem "skala",                 "~> 1.1.9", github: "ubpb/skala", branch: :master
gem "slim",                  "~> 3.0.7"
gem "sqlite3",               "~> 1.3"
gem "turbolinks",            "~> 2.5.3"
gem "uglifier",              "~> 3.0"
gem "uservoice-ruby",        "~> 0.0.11"


#
# rails-assets.org
#
# Better use three component version numbers (~> x.y.z) because js assets often
# change structure/behaviour within minor version updates.
#
source "https://rails-assets.org" do
  gem "rails-assets-animate.css",                 "~> 3.4.0"
  gem "rails-assets-imagesloaded",                "~> 3.2.0"
  gem "rails-assets-jaubourg--jquery-jsonp",      "~> 2.4.0"
  gem "rails-assets-lodash",                      "~> 3.0"
  gem "rails-assets-matchHeight",                 "~> 0.5"
  gem "rails-assets-ractive",                     "~> 0.7.3"
  gem "rails-assets-ractive-events-keys",         "~> 0.2.1"
  gem "rails-assets-relayfoods-jquery.sparkline", "~> 2.1.4"
  gem "rails-assets-urijs",                       "~> 1.16.1"
end

group :production do
  gem "newrelic_rpm", ">= 3.16"
end

group :development do
  gem "capistrano",           "~> 3.6.0"
  gem "capistrano-bundler",   "~> 1.1.4"
  gem "capistrano-rails",     "~> 1.1.7"
  gem "capistrano-rvm",       "~> 0.1.2"
  gem "letter_opener",        "~> 1.4.1"
end

group :development, :test do
  gem "pry",                "~> 0.10.3"
  gem "pry-byebug",         "~> 3.4.0"
  gem "pry-rails",          "~> 0.3.4"
  gem "pry-rescue",         "~> 1.4.4"
  gem "pry-state",          "~> 0.1.7"

  gem "puma",               "~> 3.6"
  gem "rspec-rails",        "~> 3.5"
end

group :test do
  gem "capybara",                  "~> 2.7"
  gem "codeclimate-test-reporter", "~> 0.6", require: nil
  gem "database_cleaner",          "~> 1.5"
  gem "poltergeist",               "~> 1.10"
  gem "simplecov",                 "~> 0.12"
end

