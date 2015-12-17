class HomepageController < ApplicationController
  def show
    @scope = current_scope
    @search_request = Skala::Adapter::Search::Request.new(
      queries: [{ type: "query_string", default_field: @scope.searchable_fields.first }]
    )

    @news = FeedParser.parse_rss_feed("http://blogs.uni-paderborn.de/ub-katalog?feed=rss")
  end
end
