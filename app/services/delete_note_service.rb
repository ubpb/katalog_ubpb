class DeleteNoteService < Servizio::Service
  include InstrumentedService

  attr_accessor :id
  attr_accessor :note

  def note
    @note || Note.find_by_id(id)
  end

  validates_presence_of :note

  def call
    unless note.destroy
      errors.add(:base, :failed) and return nil
    end
  end
end
