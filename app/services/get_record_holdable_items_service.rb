class GetRecordHoldableItemsService < Servizio::Service
  include UserRelatedService

  attr_accessor :adapter
  attr_accessor :id

  validates_presence_of :adapter
  validates_presence_of :ilsuserid
  validates_presence_of :id

  def call
    adapter.get_record_holdable_items(id, ilsuserid).try(:holdable_items)
  rescue
    errors[:call] = :failed and return nil
  end
end
