class GetUserNotesService < Servizio::Service
  include CachingService
  include InstrumentedService
  include UserRelatedService

  validates_presence_of :user

  def call
    user.notes
  end
end
