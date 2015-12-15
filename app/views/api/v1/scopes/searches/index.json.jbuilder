json.facets @search_result["facets"]
json.hits @search_result["hits"] do |_hit|
  _hit["record"] = _hit["record"].select { |_, _value| _value.present? }
  json.extract! _hit, *_hit.keys
end
json.total_hits @search_result["total_hits"]
