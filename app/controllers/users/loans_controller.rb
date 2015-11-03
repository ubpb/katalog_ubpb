class Users::LoansController < UsersController
  before_action -> do
    add_breadcrumb name: "users#show", url: user_path
    add_breadcrumb
  end, only: :index

  def index
    ils_adapter = KatalogUbpb.config.ils_adapter.instance
    search_engine_adapter = KatalogUbpb.config.ils_adapter.scope.search_engine_adapter.instance
    @scope = KatalogUbpb.config.ils_adapter.scope

    @loans = GetUserLoansService.call(
      adapter: ils_adapter,
      user: current_user
    )

    @search_result = SearchRecordsService.call(
      adapter: search_engine_adapter,
      search_request: @search_request = Skala::SearchRequest.new(
        queries: [
          {
            type: "ordered_terms",
            field: "id",
            terms: @loans.map(&:record_id)
          }
        ],
        size: @loans.length
      )
    )

    @records_by_id = @search_result.hits.each_with_object({}) do |_hit, _hash|
      _hash[_hit.fields["id"]] = _hit
    end
  end


=begin
  def renew
    call_operation Skala::RenewUserLoanService.new(user: current_user, loan_id: params[:id]),
    on_error: -> (op)   { flash[:error] = t(".error") },
    on_success: -> (op) { flash[:success] = t(".success") }

    redirect_to action: :index
  end

  def renew_all
    call_operation Skala::RenewUserLoansService.new(user: current_user),
    on_error: -> (op)   { flash[:error] = t(".error") },
    on_success: -> (op) { flash[:success] = t(".success") }

    redirect_to action: :index
  end
=end
end
