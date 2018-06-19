require "transformator/transformation/step"
require_relative "../request_transformation"

class Skala::ElasticsearchAdapter::Search::RequestTransformation::
  AddQuery < Transformator::Transformation::Step

  def call
    [source.queries, source.facet_queries].flatten.compact.presence.try(:each) do |_query|
      target["query"] ||= {}
      target["query"]["bool"] ||= {}
      target["query"]["bool"]["must"] ||= []
      target["query"]["bool"]["must_not"] ||= []

      if elasticsearch_query = elasticsearch_query_factory(_query)
        container = _query.exclude ? target["query"]["bool"]["must_not"] : target["query"]["bool"]["must"] 
        container << elasticsearch_query
      end
    end
  end

  private

  def elasticsearch_query_factory(query)
    case query.type.to_sym
    when :query_string        then query_from_query_string_query(query)
    when :simple_query_string then query_from_simple_query_string_query(query)
    when :match               then query_from_match_query(query)
    when :ordered_terms       then query_from_ordered_terms_query(query)
    when :range               then query_from_range_query(query)
    when :unscored_terms      then query_from_unscored_terms_query(query)
    end
  end

  def query_from_query_string_query(query)
    {
      "query_string" => {
        "default_field"    => query.default_field,
        "default_operator" => "AND",
        "fields"           => query.fields,
        "query"            => query.query
      }.compact
    }
  end

  def query_from_simple_query_string_query(query)
    {
      "simple_query_string" => {
        "default_operator" => query.default_operator,
        "fields" => query.fields,
        "query"  => query.query,
        "analyze_wildcard" => true
      }
      .compact
    }
  end

  def query_from_match_query(query)
    {
      "match" => {
        query.field => query.query
      }
    }
  end

  def query_from_ordered_terms_query(query)
    {
      "bool" => {
        "should" => query.terms.reverse.map.with_index do |_term, _reversed_index|
          {
            "constant_score" => {
              "filter" => {
                "term" => {
                  query.field => _term
                }
              },
              "boost" => _reversed_index
            }
          }
        end,
      }
    }
  end

  def query_from_range_query(query)
    {
      "range" => {
        query.field => {
          "lte" => query.lte,
          "gte" => query.gte
        }
        .compact
      }
    }
  end

  def query_from_unscored_terms_query(query)
    {
      "constant_score" => {
        "filter" => {
          "terms" => {
            query.field => query.terms
          }
        }
      }
    }
  end
end
