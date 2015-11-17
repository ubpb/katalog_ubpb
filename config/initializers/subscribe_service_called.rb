ActiveSupport::Notifications.subscribe("service_called.katalog_ubpb") do |name, started, finished, unique_id, data|
  services_path = [data[:parents], data[:service]].flatten.compact.map(&:to_s).join("/")
  elapsed_time_in_milliseconds = ((finished - started) * 1000).round(1)
  Rails.logger.info "  Called #{services_path} (#{elapsed_time_in_milliseconds}ms)"
end
