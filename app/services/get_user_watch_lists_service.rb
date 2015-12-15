class GetUserWatchListsService < Servizio::Service
  include CachingService
  include InstrumentedService
  include UserRelatedService

  attr_accessor :include

  validates_presence_of :user

  def call
    user.watch_lists.includes(@include)
  end
end
