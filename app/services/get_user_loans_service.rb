class GetUserLoansService < Servizio::Service
  include CachingService
  include UserRelatedService

  attr_accessor :adapter

  validates_presence_of :adapter
  validates_presence_of :ilsuserid

  def call
    cache(key: [self.class, ilsuserid]) do
      adapter.get_user_loans(ilsuserid).try(:loans)
    end
  rescue
    errors[:call] = :failed and return nil
  end
end
