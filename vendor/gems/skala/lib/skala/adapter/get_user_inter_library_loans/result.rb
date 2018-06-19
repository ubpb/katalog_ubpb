require "skala/adapter/operation/result"
require "skala/inter_library_loan"
require_relative "../get_user_inter_library_loans"

class Skala::Adapter::GetUserInterLibraryLoans::Result < Skala::Adapter::Operation::Result
  include Enumerable
  include Virtus.model

  attribute :inter_library_loans, Array[Skala::InterLibraryLoan]

  def each
    block_given? ? inter_library_loans.each { |_element| yield _element } : inter_library_loans.each
  end
end
