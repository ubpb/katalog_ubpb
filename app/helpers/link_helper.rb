module LinkHelper

  def link_to_new_search(query_string, scope:, sort: [{field: "_score"}], default_field:, label:nil)
    link_to (label || query_string), searches_path(
      search_request: Skala::Adapter::Search::Request.new(
        queries: [{
          type: "query_string",
          query: query_string,
          fields: [default_field]
        }],
        sort: [sort].flatten(1).compact.presence
      ),
      scope: scope.id
    )
  end

  def link_to_superorder(ht_number, scope:, label:)
    link_to_new_search(ht_number, scope: scope, default_field: "ht_number", label: label)
  end
  alias_method :link_to_ht_number, :link_to_superorder

  def link_to_volumes(ht_number, scope:, label:)
    link_to_new_search(ht_number, scope: scope, sort: [{field: "volume_count_sort2", order: "asc"}], default_field: "superorder", label: label)
  end

  def link_to_creator(creator, scope:)
    query = creator.gsub(/\[[^\]]+\]/, "").strip
    link_to_new_search(query, label: creator, scope: scope, default_field: "creator_contributor_search")
  end

  def link_to_notation(notation, scope:)
    link_to_new_search(notation, scope: scope, default_field: "notation")
  end

  def link_to_subject(subject, scope:)
    link_to_new_search(subject, scope: scope, default_field: "subject_search")
  end

  def link_to_page(scope, search_request, from)
    link_to searches_path(
      search_request: search_request.deep_dup.tap do |_search_request|
        _search_request.from = from
      end,
      scope: scope
    ),
    class: "btn btn-default" do
      yield
    end
  end

  def link_to_previous_page(scope, search_request)
    from = search_request.from - search_request.size
    enabled = search_request.from > 0

    if enabled
      link_to_page(scope, search_request, from) do
        fa_icon("angle-left")
      end
    end
  end

  def link_to_next_page(scope, search_request, total_records)
    from = search_request.from + search_request.size
    enabled = from < total_records

    if enabled
      link_to_page(scope, search_request, from) do
        fa_icon("angle-right")
      end
    end
  end

end
