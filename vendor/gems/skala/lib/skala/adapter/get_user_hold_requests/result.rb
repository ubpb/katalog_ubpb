require "skala/adapter/operation/result"
require "skala/hold_request"
require_relative "../get_user_hold_requests"

class Skala::Adapter::GetUserHoldRequests::Result < Skala::Adapter::Operation::Result
  include Enumerable
  include Virtus.model

  attribute :hold_requests, Array[Skala::HoldRequest]

  def each
    block_given? ? hold_requests.each { |_element| yield _element } : hold_requests.each
  end
end
