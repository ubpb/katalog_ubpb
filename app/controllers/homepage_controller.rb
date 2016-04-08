class HomepageController < ApplicationController
  def show
    if params[:q].present?
      search_request = Skala::Adapter::Search::Request.new(
        queries: [{ type: "query_string", query: params[:q]}]
      )

      return redirect_to(
        searches_path(scope: current_scope, search_request: search_request)
      )
    else
      @scope = current_scope
      @search_request = Skala::Adapter::Search::Request.new(
        queries: [{ type: "query_string", fields: [@scope.searchable_fields.first] }]
      )

      @news = FeedParser.parse_rss_feed("https://blogs.uni-paderborn.de/ub-katalog?feed=rss")
    end
  end
end
