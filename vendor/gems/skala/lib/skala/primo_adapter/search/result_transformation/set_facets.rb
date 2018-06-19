require "transformator/transformation/step"
require_relative "../result_transformation"

class Skala::PrimoAdapter::Search::ResultTransformation::
  SetFacets < Transformator::Transformation::Step

  def call
    requested_facets = transformation.search_request.facets

    target.facets =
    transformation.search_brief_response.xpath("//FACET")
    .map do |_source_facet|
      # in primo facet fields are named "facet_foo", while the name is "foo"
      field = "facet_#{_source_facet.attr("NAME")}"

      corresponding_search_request_facet = requested_facets.find do |_requested_facet|
        _requested_facet.field == field
      end

      case corresponding_search_request_facet.try(:type)
      when "histogram"
        target.class::HistogramFacet.new(
          field: field,
          name: corresponding_search_request_facet.name,
          entries: begin
            _source_facet.xpath("./FACET_VALUES")
            .select do |_source_facet_value|
              _source_facet_value.attr("KEY")[/\d{4}/]
            end
            .each_with_object({}) do |_source_facet_value, _hash|
              key = _source_facet_value.attr("KEY").to_i
              count = _source_facet_value.attr("VALUE").to_i

              _hash[key] = count
            end
            .tap do |_key_count_mapping|
              keys = _key_count_mapping.keys.map(&:to_i)

              (keys.min..keys.max).each do |_key_from_range|
                _key_count_mapping[_key_from_range] ||= 0
              end
            end
            .each_with_object([]) do |(_key, _count), _array|
              _array.push(count: _count, key: _key)
            end
            .sort do |_entry, _other_entry|
              _entry[:key] <=> _other_entry[:key]
            end
          end
        )
      when "terms"
        target.class::TermsFacet.new(
          field: field,
          name: corresponding_search_request_facet.name,
          terms: _source_facet.xpath("./FACET_VALUES").map do |_source_facet_value|
            {
              count: _source_facet_value.attr("VALUE").to_i,
              term: begin
                # https://github.com/ubpb/katalog_ubpb/issues/58
                # https://github.com/sparklemotion/nokogiri/issues/214
                _source_facet_value.to_s.match(/KEY="([^"]+)"/).captures.try(:first) ||
                _source_facet_value.attr("KEY")
              end
            }
          end
        )
      end
    end
    .compact
  end
end
