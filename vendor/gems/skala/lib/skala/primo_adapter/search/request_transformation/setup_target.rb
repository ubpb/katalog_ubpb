require "ox"
require "transformator/transformation/step"
require_relative "../request_transformation"

class Skala::PrimoAdapter::Search::RequestTransformation::
  SetupTarget < Transformator::Transformation::Step

  def call
    # create empty ox document
    self.target = Ox::Document.new(version: "1.0", encoding: "UTF-8")

    # populate target with soap request skeleton
    self.target << Ox.parse(
      <<-xml
        <env:Envelope
            xmlns:xsd="http://www.w3.org/2001/XMLSchema"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xmlns:impl="http://primo.kobv.de/PrimoWebServices/services/searcher"
            xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
            xmlns:ins0="http://xml.apache.org/xml-soap">
          <env:Body>
            <impl:searchBrief><searchRequestStr></searchRequestStr></impl:searchBrief>
          </env:Body>
        </env:Envelope>
      xml
    )
  end
end
