class DeleteWatchListService < Servizio::Service
  include InstrumentedService

  attr_accessor :id
  attr_accessor :watch_list

  def watch_list
    @watch_list || WatchList.find_by_id(id)
  end

  validates_presence_of :watch_list

  def call
    unless watch_list.destroy
      errors[:call] = :failed and return nil
    end
  end
end
