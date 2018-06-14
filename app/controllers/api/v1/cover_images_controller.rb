require 'open-uri'

class Api::V1::CoverImagesController < ActionController::Base

  BASE_URL = "http://api.vlb.de/api/v1/cover"
  ACCESS_TOKEN = ENV["COVER_ACCESS_TOKEN"] || "ae9dcc0d-bc22-48ca-a343-e840429fd043"
  READ_TIMEOUT = 0.5 # seconds

  def show
    id   = params[:id]
    size = params[:size].presence || "m"

    response = Rails.cache.fetch("cover-#{id}-#{size}", expires_in: 24.hours) do
      load_cover_image(id, size: size)
    end

    if response
      send_data response.body, disposition: "inline", type: response.content_type
    else
      # transparent gif
      send_data Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="), disposition: "inline", type: "image/gif"
    end
  end

private

  def load_cover_image(id, size: "m")
    uri = URI.parse("#{BASE_URL}/#{id}/#{size}?access_token=#{ACCESS_TOKEN}")
    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.read_timeout = READ_TIMEOUT
      request = Net::HTTP::Get.new(uri)
      http.request(request)
    end

    response if response.is_a?(Net::HTTPSuccess)
  rescue Net::ReadTimeout
    nil
  end

end
