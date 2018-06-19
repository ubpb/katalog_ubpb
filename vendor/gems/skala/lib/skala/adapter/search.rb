require_relative "../adapter"

class Skala::Adapter::Search < Skala::Adapter::Operation
  require_relative "./search/request"
  require_relative "./search/result"
end
