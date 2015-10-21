module SearchesHelper

  def link_to_previous_page(scope, search_request)
    from = search_request.from - search_request.size
    enabled = search_request.from > 0

    if enabled
      link_to_page(scope, search_request, from) do
        fa_icon("angle-left")
      end
    end
  end

  def link_to_next_page(scope, search_request, total_hits)
    from = search_request.from + search_request.size
    enabled = from < total_hits

    if enabled
      link_to_page(scope, search_request, from) do
        fa_icon("angle-right")
      end
    end
  end

  def page_stats(scope, search_request, total_hits)
    page_start = search_request.from + 1
    page_end   = search_request.from + search_request.size
    page_end   = total_hits if page_end > total_hits

    link_to_page(scope, search_request, 0) do
      content_tag :span, class: "page-stats" do
        "#{page_start} – #{page_end} von #{total_hits}"
      end
    end
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

  def amazon_image_url(hit, format: "THUMBZZZ")
    isbn = [*hit.fields["isbn"]].first
    if isbn
      isbn = isbn.gsub("-", "")
      "https://images-na.ssl-images-amazon.com/images/P/#{isbn}.03.#{format}.jpg"
    end
  end

end
