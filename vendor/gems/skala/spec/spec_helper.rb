if ENV["CODECLIMATE_REPO_TOKEN"]
  # report coverage only for latest mri ruby
  if RUBY_ENGINE == "ruby" && RUBY_VERSION >= "2.2.0"
    require "codeclimate-test-reporter"
    CodeClimate::TestReporter.start
  end
else
  require "simplecov"
  SimpleCov.start
end

require "skala"
require "yaml"

require "pry" rescue LoadError

RSpec.configure do |config|
  # begin --- rspec 3.1 generator
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  # end --- rspec 3.1 generator
end

def read_asset(path_to_file)
  File.read(File.expand_path(File.join(File.dirname(__FILE__), "assets", path_to_file)))
end
