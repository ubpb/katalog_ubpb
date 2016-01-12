class UpdateNoteService < Servizio::Service
  include InstrumentedService
  include Servizio::Service::DefineColumnType

  attr_accessor :current_value
  attr_accessor :id
  attr_accessor :new_value
  attr_accessor :note

  define_column_type :new_value, :text

  validates_presence_of :new_value
  validates_presence_of :note

  def current_value
    @current_value || note.try(:value)
  end

  def new_value
    @new_value.presence
  end

  def note
    @note || Note.find_by_id(id)
  end

  def call
    if note.update_attributes(value: new_value)
      note
    else
      errors[:call] = :failed and return nil
    end
  end
end
