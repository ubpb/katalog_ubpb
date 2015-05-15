source "https://rubygems.org"

gem "katalog", ">= 0",       github: "ubpb/katalog",               branch: :master
gem "sqlite3", "~> 1.3.9"

gem "aleph_api",             github: "ubpb/aleph_api",             branch: :master
gem "celsius-amazon",        github: "ubpb/celsius-amazon",        branch: :master
gem "celsius-elasticsearch", github: "ubpb/celsius-elasticsearch", branch: :master
gem "celsius-primo",         github: "ubpb/celsius-primo",         branch: :master
gem "celsius-primo_ubpb",    github: "ubpb/celsius-primo_ubpb",    branch: :master
gem "fahrenheit-aleph",      github: "ubpb/fahrenheit-aleph",      branch: :master
gem "fahrenheit-aleph_ubpb", github: "ubpb/fahrenheit-aleph_ubpb", branch: :master
#gem "fahrenheit-loopback",   github: "ubpb/fahrenheit-loopback",   branch: :master
gem "servizio",              github: "msievers/servizio",          branch: :master
gem "skala",                 github: "ubpb/skala",                 branch: :master
gem "weak_xml",              github: "msievers/weak_xml",          branch: :master

gem 'sprockets', '~> 2.12.3'

#
# rails-assets.org
#
source "https://rails-assets.org" do
  gem "rails-assets-imagesloaded",  "~> 3.1.8"
  gem "rails-assets-json3",         "~> 3.3.2"
  gem "rails-assets-jspath",        "~> 0.3.0"
  gem "rails-assets-lodash-compat", "~> 3.0.0"
  gem "rails-assets-matchHeight",   "~> 0.5.2"
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
  gem "dotenv-rails",       "~> 1.0.2"
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

