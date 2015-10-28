module UrlUtils

  protected

  def get_url(url, data = {})
    uri       = get_uri(url, data)
    http      = get_http_connection(uri)

    request = Net::HTTP::Get.new(uri.request_uri)
    request.set_form_data(data)

    response = http.request(request)
    response.body
  end

  def get_uri(url, params = {})
    url = "#{url}?#{params.collect{|k,v| "#{k.to_s}=#{v.to_s}"}.join('&')}" if params.present?
    URI.parse(URI.escape(url))
  end

  def get_http_connection(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    return http
  end

end