class RenewUserLoanService < Servizio::Service
  include InstrumentedService
  include UserRelatedService

  attr_accessor :adapter
  attr_accessor :loan_id

  validates_presence_of :adapter
  validates_presence_of :ils_user_id
  validates_presence_of :loan_id

  def call
    adapter.renew_user_loan(ils_user_id, loan_id)
  rescue Skala::Adapter::Error
    errors[:call] = :failed and return nil
  end
end
