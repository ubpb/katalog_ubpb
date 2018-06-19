require "skala/adapter/search"
require_relative "../primo_adapter"

class Skala::PrimoAdapter::Search < Skala::Adapter::Search
  require_relative "./search/request_transformation"
  require_relative "./search/result_transformation"

  def call(search_request, options = {})
    primo_soap_request = RequestTransformation.new.call(search_request, adapter, options)
    primo_result = adapter.soap_api.searchBrief(primo_soap_request)
    ResultTransformation.new.call(primo_result, search_request: search_request)
  end
end
