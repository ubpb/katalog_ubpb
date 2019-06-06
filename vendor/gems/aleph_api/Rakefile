require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :benchmark do
  require_relative "./benchmark/joffrey/mab_document"
  require_relative "./benchmark/joffrey/mab_xml_parser"

  #Benchmark::Joffrey::MabDocument.new.call
  Benchmark::Joffrey::MabXmlParser.new.call
end
