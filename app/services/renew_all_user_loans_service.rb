class RenewAllUserLoansService < Servizio::Service
  include UserRelatedService

  attr_accessor :adapter

  validates_presence_of :adapter
  validates_presence_of :ils_user_id

  def call
    user_loans = GetUserLoansService.call(
      adapter: adapter,
      ils_user_id: ils_user_id
    )

    if user_loans.blank?
      errors[:call] = :no_loans_present and return nil
    else
      renew_loans_result = adapter.renew_user_loans(ils_user_id)
      renewed_loans = renew_loans_result.renewed_loans

      if user_loans.length != renewed_loans.length
        errors[:call] = :not_all_loans_could_be_renewed
      end

      return renewed_loans
    end
  rescue Skala::Adapter::Error
    errors[:call] = :failed and return nil
  end
end
