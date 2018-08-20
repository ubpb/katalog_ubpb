require 'open-uri'

class Api::V1::CoverImagesController < ActionController::Base

  ENABLED      = KatalogUbpb.config.cover_images["enabled"] || false
  BASE_URL     = KatalogUbpb.config.cover_images["base_url"] || "http://api.vlb.de/api/v1/cover"
  ACCESS_TOKEN = KatalogUbpb.config.cover_images["access_token"]
  READ_TIMEOUT = KatalogUbpb.config.cover_images["read_timeout"] || 0.5

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
    if ENABLED && ACCESS_TOKEN.present?
      uri = URI.parse("#{BASE_URL}/#{id}/#{size}?access_token=#{ACCESS_TOKEN}")
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
