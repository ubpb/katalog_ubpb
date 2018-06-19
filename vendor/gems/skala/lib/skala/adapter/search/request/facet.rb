require_relative "../request"

class Skala::Adapter::Search::Request::Facet
  include Virtus.model

  attribute :type, String, default: -> (instance, _) do
    class_name = instance.class.to_s.demodulize.underscore

    if (splitted_class_name = class_name.split("_")).last == "facet"
      splitted_class_name[0..-2].join("_")
    else
      class_name
    end
  end

  require_relative "./histogram_facet"
  require_relative "./range_facet"
  require_relative "./terms_facet"

  def self.factory(options)
    if (options[:type] || options["type"]) == "histogram"
      parent::HistogramFacet.new(options)
    elsif (options[:type] || options["type"]) == "range"
      parent::RangeFacet.new(options)
    elsif (options[:type] || options["type"]) == "terms"
      parent::TermsFacet.new(options)
    end
  end
end
