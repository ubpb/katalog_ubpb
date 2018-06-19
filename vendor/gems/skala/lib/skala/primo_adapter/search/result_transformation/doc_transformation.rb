require "transformator/transformation"
require_relative "../result_transformation"

class Skala::PrimoAdapter::Search::ResultTransformation::
  DocTransformation < Transformator::Transformation

  require_directory "#{File.dirname(__FILE__)}/doc_transformation"

  def call(source, options = {})
    options[:target] ||= Skala::Adapter::Search::Result::Hit.new(record: {})
    super(source, options)
  end

  sequence [
    SetMetadata,
    [ # fields
      SetId,
      SetContentType,
      SetCreator,
      SetTitle,
      SetYearOfPublication,
      SetEdition,
      SetPublisher,
      SetSubject,
      SetLanguage,
      SetDescription,
      SetSource,
      SetIsPartOf,
      SetIdentifier,
      SetOpenurl,
      SetFulltextAvailable
    ],
    #AddImage, # needs isbn to be present
  ]

  def read_source_values(xpath, split: nil)
    source.xpath(xpath).map do |e|
      if split
        e.content.try do |c|
          c.split(split).map(&:strip)
        end
      else
        e.content
      end
    end.flatten.compact
  end
end
