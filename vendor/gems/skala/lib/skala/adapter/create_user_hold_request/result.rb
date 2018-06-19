require "skala/adapter/operation/result"
require "skala/hold_request"
require_relative "../create_user_hold_request"

class Skala::Adapter::CreateUserHoldRequest::Result < Skala::Adapter::Operation::Result
  include Virtus.model

  attribute :success, Boolean
  attribute :source
end
