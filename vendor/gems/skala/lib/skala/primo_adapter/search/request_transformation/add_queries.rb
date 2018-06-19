require "ox"
require "transformator/transformation/step"
require_relative "../request_transformation"

class Skala::PrimoAdapter::Search::RequestTransformation::
  AddQueries < Transformator::Transformation::Step

  def call
    query_terms_node = transformation.inner_search_request.locate("PrimoSearchRequest/QueryTerms").first

    [source.queries, source.facet_queries].flatten.compact.presence.try(:each) do |_query|
      if primo_query = query_factory(_query)
        [primo_query].flatten(1).each do |_primo_query|
          query_terms_node << _primo_query
        end
      end
    end
  end

  private

  def query_factory(query)
    case query.type.to_sym
    when :ids                 then query_from_ids_query(query)
    when :match               then query_from_match_query(query)
    when :query_string        then query_from_query_string_query(query)
    when :range               then query_from_range_query(query)
    when :simple_query_string then query_from_query_string_query(query) # supports also simple_query_string_query
    else raise "Unsupported query type!"
    end
  end

  def query_from_ids_query(query)
    query.query.map do |_id|
      Ox.parse(
        <<-xml.strip_heredoc
          <QueryTerm>
            <IndexField>#{map_query_field("id")}</IndexField>
            <PrecisionOperator>exact</PrecisionOperator>
            <Value>#{_id}</Value>
          </QueryTerm>
        xml
      )
    end
  end

  def query_from_match_query(query)
    # ! attention ! <Value/> is required in front off includeValue/excludeValue
    Ox.parse(
      <<-xml.strip_heredoc
        <QueryTerm>
          <IndexField>#{map_query_field(query.field)}</IndexField>
          <PrecisionOperator>exact</PrecisionOperator>
          #{query.exclude? ? '<Value/><excludeValue>' : '<Value>'}#{query.query}#{query.exclude? ? '</excludeValue>' : '</Value>'}
        </QueryTerm>
      xml
    )
  end

  def query_from_range_query(query)
    Ox.parse(
      <<-xml
        <QueryTerm>
          <IndexField>#{query.field}</IndexField>
          <PrecisionOperator>exact</PrecisionOperator>
          <Value>[#{query.gte} TO #{query.lte}]</Value>
        </QueryTerm>
      xml
    )
  end

  def query_from_query_string_query(query)
    normalized_query =
    if query.default_operator.upcase == "OR"
      query.query.split(" ").join(" OR ")
    else
      query.query
    end

    Ox.parse(
      <<-xml
        <QueryTerm>
          <IndexField>#{map_query_field(query.try(:default_field) || query.try(:fields).try(:first))}</IndexField>
          <PrecisionOperator>contains</PrecisionOperator>
          <Value>#{normalized_query}</Value>
        </QueryTerm>
      xml
    )
  end

  def map_query_field(field)
    case field
    when 'id' then 'rid'
    else
      field
    end
  end
end
