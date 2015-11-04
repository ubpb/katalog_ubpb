class Users::FormerLoansController < UsersController
  MAX_FORMER_LOANS ||= 100

  before_action -> do
    add_breadcrumb name: "users#show", url: user_path
    add_breadcrumb
  end, only: :index

  def index
    ils_adapter = KatalogUbpb.config.ils_adapter.instance
    search_engine_adapter = KatalogUbpb.config.ils_adapter.scope.search_engine_adapter.instance
    @scope = KatalogUbpb.config.ils_adapter.scope

    @former_loans = GetUserFormerLoansService.call(
      adapter: ils_adapter,
      user: current_user
    ).try(:[], 0..MAX_FORMER_LOANS)

    @search_result = SearchRecordsService.call(
      adapter: search_engine_adapter,
      search_request: @search_request = Skala::SearchRequest.new(
        queries: [
          {
            type: "ordered_terms",
            field: "id",
            terms: @former_loans.map(&:record_id)
          }
        ],
        size: @former_loans.length
      )
    )

    @records_by_id = @search_result.hits.each_with_object({}) do |_hit, _hash|
      _hash[_hit.fields["id"]] = _hit
    end
  end
end
