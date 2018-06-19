require "skala/adapter/operation/result"
require "skala/transaction"
require_relative "../get_user_transactions"

class Skala::Adapter::GetUserTransactions::Result < Skala::Adapter::Operation::Result
  include Enumerable
  include Virtus.model

  attribute :transactions, Array[Skala::Transaction]

  def each
    block_given? ? transactions.each { |_element| yield _element } : transactions.each
  end

  def cash_balance
    if transactions.present?
      sum_of_credits  = transactions.select { |_transaction| _transaction.type == :credit }.sum(&:value) || 0
      sum_of_debits   = transactions.select { |_transaction| _transaction.type == :debit }.sum(&:value) || 0
      sum_total       = sum_of_credits - sum_of_debits
    else
      0
    end
  end

end
