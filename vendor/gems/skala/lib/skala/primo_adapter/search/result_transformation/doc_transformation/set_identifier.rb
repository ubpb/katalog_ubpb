require "transformator/transformation/step"
require_relative "../doc_transformation"

class Skala::PrimoAdapter::Search::ResultTransformation::DocTransformation::
  SetIdentifier < Transformator::Transformation::Step

  def call
    sanitizer = Rails::Html::FullSanitizer.new

    identifier_strings = transformation.read_source_values(".//display/identifier", split: ";")
    identifier_strings.map!{|s| sanitizer.sanitize(s)}

    isbns = extract_isbns(identifier_strings)
    issns = extract_issns(identifier_strings)
    dois  = extract_dois(identifier_strings)

    target.record.isbn = isbns
    target.record.issn = issns
    target.record.identifier = dois.map{|i| {type: "doi", value: i}}
  end

private

  def extract_isbns(identifier_strings)
    extract(identifier_strings, /(isbn:|e-isbn:)\s+([a-z0-9\-\.\/]+)/i, match_index: 1)
  end

  def extract_issns(identifier_strings)
    extract(identifier_strings, /(issn:|e-issn:)\s+([a-z0-9\-\.\/]+)/i, match_index: 1)
  end

  def extract_dois(identifier_strings)
    extract(identifier_strings, /doi:\s+([a-z0-9\-\.\/]+)/i)
  end

  def extract(identifier_strings, regexp, match_index: 0)
    values = []

    identifier_strings.each do |s|
      values += s.scan(regexp).map{|r| r[match_index]}
    end

    values.compact
  end

end
