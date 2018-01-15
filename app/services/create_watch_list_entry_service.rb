class CreateWatchListEntryService < Servizio::Service
  include InstrumentedService
  include UserRelatedService

  attr_accessor :record_id
  attr_accessor :scope_id
  attr_accessor :watch_list
  attr_accessor :watch_list_id

  def watch_list
    @watch_list || (watch_list_id && WatchList.find_by_id(watch_list_id))
  end

  validates_presence_of :scope_id
  validates_presence_of :record_id
  validates_presence_of :watch_list

  def call
    watch_list.watch_list_entries.create!(
      record_id: record_id,
      scope_id: scope_id
    )
  rescue ActiveRecord::RecordInvalid
    errors.add(:call, :failed) and return nil
  end
end
