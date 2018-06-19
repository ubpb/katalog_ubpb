require_relative "../result"

class Skala::Adapter::Search::Result::Facet
  include Virtus.model

  attribute :type, String, default: -> (instance, _) do
    class_name = instance.class.to_s.demodulize.underscore

    if (splitted_class_name = class_name.split("_")).last == "facet"
      splitted_class_name[0..-2].join("_")
    else
      class_name
    end
  end
end
