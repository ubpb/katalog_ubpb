require "active_support"
require "active_support/core_ext"
require "aleph_api/version"

module AlephApi
  require_relative "./aleph_api/restful_api_client"
  require_relative "./aleph_api/x_services_client"
end
