require "skala/record"
require_relative "../result"

class Skala::Adapter::Search::Result::Hit
  include Virtus.model

  attribute :id,      String, required: true
  attribute :index,   String
  attribute :score,   BasicObject # TODO: can we set this to Float ?
  attribute :type,    String
  attribute :record,  Skala::Record
  attribute :version, Integer
end
