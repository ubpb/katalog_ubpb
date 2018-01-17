class UpdateWatchListService < Servizio::Service
  include InstrumentedService
  include Servizio::Service::DefineColumnType

  attr_accessor :current_description
  attr_accessor :current_name
  attr_accessor :new_description
  attr_accessor :new_name
  attr_accessor :watch_list

  define_column_type :new_description, :text

  validates_presence_of :new_name

  def current_description
    @current_description || watch_list.try(:description)
  end

  def current_name
    @current_name || watch_list.try(:name)
  end

  def new_description
    @new_description.presence
  end

  def call
    if @watch_list.update_attributes(name: new_name, description: new_description)
      @watch_list
    else
      errors.add(:base, :failed) and return nil
    end
  end
end
