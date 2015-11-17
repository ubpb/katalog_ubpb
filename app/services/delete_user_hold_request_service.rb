class DeleteUserHoldRequestService < Servizio::Service
  include InstrumentedService
  include UserRelatedService

  attr_accessor :adapter
  attr_accessor :id

  validates_presence_of :adapter
  validates_presence_of :id
  validates_presence_of :ils_user_id

  def call
    adapter.delete_user_hold_request(ils_user_id, id)
  rescue Skala::Adapter::DeleteUserHoldRequest::HoldRequestMissingError
    errors[:call] = :hold_request_missing and return nil
  rescue Skala::Adapter::Error
    errors[:call] = :failed and return nil
  end
end
