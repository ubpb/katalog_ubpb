class DeleteWatchListEntryService < Servizio::Service
  include InstrumentedService

  attr_accessor :id
  attr_accessor :watch_list_entry

  def watch_list_entry
    @watch_list_entry || WatchListEntry.find_by_id(id)
  end

  validates_presence_of :id

  def call
    watch_list_entry.destroy
  rescue #ActiveRecord::RecordInvalid
    errors.add(:call, :failed) and return nil
  end
end
