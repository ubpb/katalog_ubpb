class GetUserNotesService < Servizio::Service
  include InstrumentedService
  include UserRelatedService

  validates_presence_of :user

  def call
    user.notes
  end
end
