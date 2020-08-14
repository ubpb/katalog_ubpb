require "transformator/transformation/step"
require_relative "../result_transformation"

class Skala::PrimoAdapter::Search::ResultTransformation::
  FixPrimoFacetsBugs < Transformator::Transformation::Step

  def call
    # please do not change order of the calls below, because they depend (in parts) on each other
    fix_selected_facet_is_missing
    fix_selected_facets_occur_slightly_different
    fix_selected_facet_value_is_missing
    fix_creationdate_facet_values_out_of_selected_range
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

  def fix_selected_facet_is_missing
    requested_facets = transformation.search_request.facets

    transformation.search_request.facet_queries.each do |_facet_query|
      target_facet = target.facets.find { |_facet| _facet.field == _facet_query.field }

      unless target_facet
        requested_facet = requested_facets.find do |requested_facet|
          requested_facet.field == _facet_query.field
        end

        if requested_facet
          # Handling case for Terms facet
          if requested_facet.type.to_s == "terms"
            target.facets << target.class::TermsFacet.new(
              field: _facet_query.field,
              name: requested_facet.name,
              terms: []
            )
          end
        end
      end
    end
  end

  def fix_selected_facet_value_is_missing
    transformation.search_request.facet_queries.each do |_facet_query|
      target_facet = target.facets.find { |_facet| _facet.field == _facet_query.field }

      if target_facet && !_facet_query.exclude?
        # Handling case for Terms facets
        if target_facet.type.to_s == "terms"
          if target_facet.terms.none? { |_term| _term.term == _facet_query.query }
            target_facet.terms << target.class::TermsFacet::Term.new(
              count: target.total_hits,
              term: _facet_query.query
            )
          end
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
