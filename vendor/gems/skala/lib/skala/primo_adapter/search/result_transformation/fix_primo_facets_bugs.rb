require "transformator/transformation/step"
require_relative "../result_transformation"

class Skala::PrimoAdapter::Search::ResultTransformation::
  FixPrimoFacetsBugs < Transformator::Transformation::Step

  def call
    # please do not change order of the calls below, because they depend (in parts) on each other
    fix_selected_facets_occur_slightly_different
    fix_selected_facet_value_is_missing
    fix_creationdate_facet_values_out_of_selected_range
    # case 1 - there is no facet at all
    #transformation.search_request.facets.each do |_requested_facet|
    #  binding.pry
    #end
=begin
    request[:body]["facets"].try do |_requested_facets|
      _requested_facets.each do |_facet_name, _requested_facet|
        unless target["facets"][_facet_name]
          if _requested_facet.keys.include?("terms")
            target["facets"][_facet_name] = {
              "_type" => "terms",
              "terms" => []
            }
          end
        end
      end
    end
=end

    # case 2 - there is a facet, but the requested facet is not included
=begin
    deep_locate(
      request,
      -> (_key, _value, _) do
        _key == "match" && _value.keys.any? do |__key|
          __key.start_with?("facet")
        end
      end
    )
    .presence
    .try do |_facet_queries|
      _facet_queries.each do |_facet_query|
        _facet_query["match"].try do |_match_query|
          target["facets"][_match_query.keys.first]["terms"].try do |_target_facet_terms|
            if _target_facet_terms.none? { |_term| _term["term"] == _match_query.values.first }
              _target_facet_terms << {
                "term" => _match_query.values.first,
                "count" => 1
              }
            end
          end
        end
      end
    end
=end
  end

  private

  def fix_creationdate_facet_values_out_of_selected_range
    creationdate_facet_query = transformation.search_request.facet_queries.find do |_facet_query|
      _facet_query.field == "facet_creationdate"
    end

    creationdate_facet = target.facets.find do |_target_facet|
      _target_facet.field == "facet_creationdate"
    end

    if creationdate_facet && creationdate_facet_query
      creationdate_facet.entries.select! do |_entry|
        _entry.key.to_i >= creationdate_facet_query.gte.to_i &&
        _entry.key.to_i <= creationdate_facet_query.lte.to_i
      end
    end
  end

  def fix_selected_facet_value_is_missing
    transformation.search_request.facet_queries.each do |_facet_query|
      target_facet = target.facets.find { |_facet| _facet.field == _facet_query.field }

      if _facet_query.type.to_s == "match" && !_facet_query.exclude? && target_facet && target_facet.type.to_s == "terms"
        if target_facet.terms.none? { |_term| _term.term == _facet_query.query }
          term_class = target_facet.terms.first.class

          target_facet.terms.push term_class.new(
            count: target.total_hits,
            term: _facet_query.query
          )
        end
      end
    end
  end

  def fix_selected_facets_occur_slightly_different
    transformation.search_request.facet_queries.each do |_facet_query|
      target_facet = target.facets.find { |_facet| _facet.field == _facet_query.field }

      if _facet_query.type.to_s == "match" && target_facet && target_facet.type.to_s == "terms"
        target_facet.terms.each do |_target_facet_term|
          if _target_facet_term.term.downcase.strip == _facet_query.query.downcase
            _target_facet_term.term = _facet_query.query
          end
        end
      end
    end
  end
end
