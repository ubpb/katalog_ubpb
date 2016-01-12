class CreateNoteService < Servizio::Service
  include InstrumentedService
  include UserRelatedService

  attr_accessor :record_id
  attr_accessor :scope_id
  attr_accessor :value

  validates_presence_of :record_id
  validates_presence_of :scope_id
  validates_presence_of :user
  validates_presence_of :value

  def call
    user.notes.create!(record_id: record_id, scope_id: scope_id, value: value)
  rescue ActiveRecord::RecordInvalid
    errors[:call] = :failed and return nil
  end
end
