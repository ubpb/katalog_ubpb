class HomepageController < ApplicationController
  def show
    @search_request = Skala::SearchRequest.new({
      queries: Skala::SearchRequest::SimpleQueryStringQuery.new({
        field: current_scope.searchable_fields.first
      })
    })
  end
end
