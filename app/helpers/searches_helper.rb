module SearchesHelper

  def link_to_superorder(scope, superorder)
    link_to superorder["label"], searches_path(
      search_request: Skala::SearchRequest.new(
        queries: {
          type: "query_string",
          query: superorder["ht_number"],
          default_field: "ht_number"
        }
      ),
      scope: scope.id
    )
  end

  # TODO: Add sort for volume count
  def link_to_volumes(scope, superorder)
    link_to searches_path(
      search_request: Skala::SearchRequest.new(
        queries: {
          type: "query_string",
          query: superorder["ht_number"],
          default_field: "superorder"
        }
      ),
      scope: scope.id
    ) do
      "(#{t('.all_parts', default: "all volumes")})"
    end
  end

end
