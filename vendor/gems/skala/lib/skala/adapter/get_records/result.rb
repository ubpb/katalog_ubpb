require "skala/adapter/operation/result"
require "skala/record"
require_relative "../get_records"

class Skala::Adapter::GetRecords::Result < Skala::Adapter::Operation::Result
  # This is the GetRecords::Result::Record, the object which holds meta informations
  # and has a record property, which holds the actual Skala::Record.
  class Record
    include Virtus.model

    attribute :found, Boolean, default: false
    attribute :id, String
    attribute :index, String
    attribute :record, Skala::Record
    attribute :type, String
    attribute :version, Integer
  end

  include Enumerable
  include Virtus.model

  attribute :records, Array[Record]
  attribute :source, String

  def each
    block_given? ? records.each { |_element| yield _element } : records.each
  end
end
