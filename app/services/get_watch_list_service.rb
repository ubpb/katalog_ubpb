class GetWatchListService < Servizio::Service
  include CachingService
  include InstrumentedService

  attr_accessor :id

  validates_presence_of :id

  def call
    WatchList.includes(:watch_list_entries).find_by_id(id)
  end
end
