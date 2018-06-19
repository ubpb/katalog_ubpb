require "nokogiri"
require "skala/adapter/get_user_former_loans"
require_relative "../aleph_adapter"
require_relative "./get_user_loans"

class Skala::AlephAdapter::GetUserFormerLoans < Skala::Adapter::GetUserFormerLoans
  def call(username, options = {})
    get_user_loans_result = get_user_loans(username, type: :history, limit: options[:limit])

    self.class::Result.new(
      former_loans: get_user_loans_result.loans,
      source: get_user_loans_result.source
    )
  end

  private

  def get_user_loans(*args)
    adapter.class::GetUserLoans.new(adapter).call(*args)
  end
end
