class RenewAllUserLoansService < Servizio::Service
  include InstrumentedService
  include UserRelatedService

  attr_accessor :adapter

  validates_presence_of :adapter
  validates_presence_of :ils_user_id

  def call
    user_loans = GetUserLoansService.call(
      adapter: adapter,
      ils_user_id: ils_user_id,
      parents: parents << self.class
    )

    if user_loans.blank?
      errors.add(:base, :no_loans_present) and return nil
    else
      renew_loans_result = adapter.renew_user_loans(ils_user_id)
      renewed_loans      = renew_loans_result.renewed_loans

      if renewed_loans.count == 0
        errors.add(:base, :no_loans_could_be_renewed)
      elsif user_loans.count != renewed_loans.count
        errors.add(:base, :not_all_loans_could_be_renewed)
      end

      return renewed_loans
    end
  rescue Skala::Adapter::Error
    errors.add(:base, :failed) and return nil
  end
end
