require "skala/adapter/operation/result"
require "skala/loan"
require_relative "../get_user_loans"

class Skala::Adapter::GetUserLoans::Result < Skala::Adapter::Operation::Result
  include Enumerable
  include Virtus.model

  attribute :loans, Array[Skala::Loan]

  def each
    block_given? ? loans.each { |_element| yield _element } : loans.each
  end
end
