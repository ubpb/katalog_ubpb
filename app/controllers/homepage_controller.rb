class HomepageController < ApplicationController
  def show
    @scope = current_scope
    @search_request = Skala::Adapter::Search::Request.new(
      queries: [{ type: "simple_query_string", fields: [@scope.searchable_fields.first] }]
    )
  end
end
