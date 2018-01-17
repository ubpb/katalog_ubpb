class CreateWatchListService < Servizio::Service
  include Servizio::Service::DefineColumnType

  include InstrumentedService
  include UserRelatedService

  attr_accessor :description
  attr_accessor :name

  define_column_type :description, :text

  validates_presence_of :name
  validates_presence_of :user

  def call
    user.watch_lists.create!(description: description, name: name)
  rescue ActiveRecord::RecordInvalid
    errors.add(:base, :failed) and return nil
  end
end
