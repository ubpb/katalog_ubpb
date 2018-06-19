source "https://rubygems.org"

gem "autoprefixer-rails",    "~> 6.4.1"
gem "bibtex-ruby",           "~> 4.4.2", require: "bibtex"
gem "bootstrap-sass",        "~> 3.3.7"
gem "browser",               "~> 2.2.0"
gem "cancancan",             "~> 1.15"
gem "coffee-rails",          "~> 4.2.1"
gem "dotenv-rails",          "~> 2.2.1"
gem "font-awesome-rails",    "~> 4.7.0"
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
gem "rails",                 "~> 5.1.0"
gem "rails-html-sanitizer",  "~> 1.0.4"
gem "rails-i18n",            "~> 5.0.0"
gem "rinku",                 "~> 2.0.0"
gem "roadie-rails",          "~> 1.2.1"
gem "sass-rails",            "~> 5.0.6"
gem "simple_form",           "~> 3.5.0"
gem "skala",                 "~> 1.2.0", path: "vendor/gems/skala"
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
  gem "therubyracer", ">= 0.12.3"
  gem "newrelic_rpm", ">= 4.5.0"
end

group :development, :test do
  gem "pry-byebug", ">= 3.5.0"
  gem "pry-rails",  ">= 0.3.6"
end

group :development do
  gem "puma",               ">= 3.11"
  gem "capistrano",         "~> 3.9.1"
  gem "capistrano-bundler", "~> 1.3.0"
  gem "capistrano-rails",   "~> 1.3.0"
  gem "capistrano-rvm",     "~> 0.1.2"
  gem "letter_opener",      "~> 1.4.1"
  gem "listen",             ">= 3.0.5", "< 3.2"
  gem "web-console",        ">= 3.3.0"
end
