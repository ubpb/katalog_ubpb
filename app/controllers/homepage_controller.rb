class HomepageController < ApplicationController
  def show
    @scope = current_scope
    @search_request = Skala::SearchRequest.new({
      queries: Skala::SearchRequest::QueryStringQuery.new({
        default_field: @scope.searchable_fields.first
      })
    })
  end
end
