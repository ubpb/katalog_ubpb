if @search_result.facets.present?
  json.facets @search_result.facets
end

json.hits @search_result.hits
json.total_hits @search_result.total_hits

if @search_result.source.present?
  json.source @search_result.source
end
