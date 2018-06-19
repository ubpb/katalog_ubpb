require "skala/adapter/operation/result"
require "skala/loan"
require_relative "../get_user_former_loans"

class Skala::Adapter::GetUserFormerLoans::Result < Skala::Adapter::Operation::Result
  include Enumerable
  include Virtus.model

  attribute :former_loans, Array[Skala::Loan]

  def each
    block_given? ? former_loans.each { |_element| yield _element } : former_loans.each
  end
end
