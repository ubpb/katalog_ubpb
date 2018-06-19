require_relative "../aleph_adapter"

module Skala::AlephAdapter::ResolveUser
  # @depends_on instance methode #adapter
  def resolve_user(username, options = {})
    username = username.upcase
    user_library = options[:user_library] || adapter.default_user_library

    x_services_result = adapter.x_services.post(
      op: "bor-by-key",
      bor_id: username,
      library: user_library
    )

    x_services_result.match(/<internal-id>(.*)<\/internal-id>/) do |_match_data|
      _match_data.captures.first
    end
  end
end
