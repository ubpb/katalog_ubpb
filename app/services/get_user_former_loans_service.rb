class GetUserFormerLoansService < Servizio::Service
  include UserRelatedService

  attr_accessor :adapter

  validates_presence_of :adapter
  validates_presence_of :ilsuserid

  def call
    adapter.get_user_former_loans(ilsuserid).try(:former_loans)
  rescue
    errors[:call] = :failed and return nil
  end
end
