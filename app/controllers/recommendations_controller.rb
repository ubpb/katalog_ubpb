class RecommendationsController < ApplicationController

  BASE_URL = "http://recommender.service.exlibrisgroup.com/service/recommender/openurl"
  ACCESS_TOKEN = "93a9b9c1f44e1d2528f4b51e21b4257c" #ENV["BX_ACCESS_TOKEN"]
  READ_TIMEOUT = 2.0 # secondss

  def show
    openurl_params = params.reject{|k,_| ["action", "controller", "scope"].include?(k)}.permit!
    response = load_recommendations(openurl_params)
    if response
      @recommendations = []
      xml = Nokogiri::XML(response.body).remove_namespaces!
      xml.xpath("//referent/*/metadata").each.with_index do |metadata_node, i|
        next if i == 0 # The first recommendation is always the requested record

        node = metadata_node.first_element_child
        case node.name
        when "journal" then
          @recommendations << {
            type: :journal,
            authors: node.xpath("authors/author").map { |author_node|
              first = author_node.at_xpath("aufirst")&.text&.presence
              last = author_node.at_xpath("aulast")&.text&.presence
              [last, first].compact.join(", ")
            },
            atitle: node.at_xpath("atitle")&.text&.presence,
            jtitle: node.at_xpath("jtitle")&.text&.presence,
            date: node.at_xpath("date")&.text&.presence,
            volume: node.at_xpath("volume")&.text&.presence,
            issue: node.at_xpath("issue")&.text&.presence,
          }
        when "book" then
          @recommendations << {
            type: :book,
            authors: node.xpath("authors/author").map { |author_node|
              first = author_node.at_xpath("aufirst")&.text&.presence
              last = author_node.at_xpath("aulast")&.text&.presence
              [last, first].compact.join(", ")
            },
            title: node.at_xpath("title")&.text&.presence,
            isbn: node.at_xpath("isbn")&.text&.presence,
            date: node.at_xpath("date")&.text&.presence,
          }
        end
      end
    end
  end

private

  def load_recommendations(openurl_params)
    if ACCESS_TOKEN.present?
      uri = URI.parse("#{BASE_URL}?token=#{ACCESS_TOKEN}&format=xml&#{openurl_params.to_query}")
      response = Net::HTTP.start(uri.host, uri.port) do |http|
        http.read_timeout = READ_TIMEOUT
        request = Net::HTTP::Get.new(uri)
        http.request(request)
      end

      response if response.is_a?(Net::HTTPSuccess)
    end
  rescue Net::ReadTimeout
    nil
  end

end