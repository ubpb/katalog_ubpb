require "faraday"
require "timeout"
require_relative "../soap_api"

class Skala::PrimoAdapter::SoapApi::SearchBrief
  attr_accessor :adapter

  def initialize(adapter)
    self.adapter = adapter
  end

  def call(request)
    begin
      Timeout::timeout(adapter.timeout) do
        Faraday.post(adapter.soap_api_url, request, {
          "Content-Type" => "application/xml", # necessary since new soap endpoint (else -> premature end of file error)
          "SOAPAction" => "searchBrief" 
        })
        .body
      end
    rescue Timeout::Error
      raise Timeout::Error, "Primo search request aborted! The server has not responded within #{adapter.timeout} seconds!"
    end
  end
end
