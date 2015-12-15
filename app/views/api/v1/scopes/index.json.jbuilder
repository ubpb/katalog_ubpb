json.array! @scopes do |_scope|
  json.(_scope, :id, :facets, :searchable_fields, :sortable_fields)
end
