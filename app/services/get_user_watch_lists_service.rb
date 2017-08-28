class GetUserWatchListsService < Servizio::Service
  include InstrumentedService
  include UserRelatedService

  attr_accessor :include

  validates_presence_of :user

  def call
    user.watch_lists.includes(@include).order("name asc")
  end
end
