class CreateWatchListService < Servizio::Service
  include InstrumentedService
  include UserRelatedService

  attr_accessor :description
  attr_accessor :name

  validates_presence_of :name
  validates_presence_of :user

  def call
    user.watch_lists.create!(description: description, name: name)
  rescue ActiveRecord::RecordInvalid
    errors[:call] = :failed and return nil
  end
end
