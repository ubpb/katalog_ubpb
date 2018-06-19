require_relative "../request"

class Skala::Adapter::Search::Request::Query
  include Virtus.model

  attribute :exclude, Axiom::Types::Boolean, default: false

  # unless given, interfere the query type from the class name
  attribute :type, String, default: -> (instance, _) do
    query_name = instance.class.to_s.demodulize.underscore

    if (splitted_query_name = query_name.split("_")).last == "query"
      splitted_query_name[0..-2].join("_")
    else
      query_name
    end
  end

  def exclude?
    exclude == true
  end
end
