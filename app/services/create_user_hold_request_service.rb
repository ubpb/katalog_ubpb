class CreateUserHoldRequestService < Servizio::Service
  include InstrumentedService
  include UserRelatedService

  attr_accessor :adapter
  attr_accessor :record_id

  validates_presence_of :adapter
  validates_presence_of :ils_user_id
  validates_presence_of :record_id

  def call
    adapter.create_user_hold_request(ils_user_id, record_id).try(:success)
  rescue Skala::Adapter::CreateUserHoldRequest::AlreadyRequestedError
    errors.add(:base, :already_requested) and return nil
  rescue Skala::Adapter::BadRequestError
    errors.add(:base, :bad_request) and return nil
  rescue Skala::Adapter::RequestFailedError
    errors.add(:base, :request_failed) and return nil
  end
end
