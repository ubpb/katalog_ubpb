begin
  require "pry"
rescue LoadError
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

def asset_path
  File.expand_path(File.join(File.dirname(__FILE__), "assets"))
end

def read_asset(path_to_file)
  File.read(File.join(asset_path, path_to_file))
end
