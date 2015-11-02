class GetUserHoldRequestsService < Servizio::Service
  include CachingService
  include UserRelatedService

  attr_accessor :adapter

  validates_presence_of :adapter
  validates_presence_of :ilsuserid

  def call
    cache(key: [self.class, ilsuserid]) do
      adapter.get_user_hold_requests(ilsuserid).try(:hold_requests)
    end
  end
end
