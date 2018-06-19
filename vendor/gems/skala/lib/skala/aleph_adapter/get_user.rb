require "skala/adapter/get_user"
require "skala/get_user_result"
require_relative "../aleph_adapter"

class Skala::AlephAdapter::GetUser < Skala::Adapter::GetUser
  def call(username, options = {})
    user_library = options[:user_library] || @adapter.default_user_library
    username = username.upcase # ensure that username/id is always upcased for request/result

    raw_aleph_result = @adapter.x_services.post(
      op: :"bor-info",
      bor_id: username,
      library: user_library,
      cash: "N",
      hold: "N",
      loans: "N"
    )

    if raw_aleph_result.include?("<error>")
      return nil
    else
      fields = Hash.from_xml(raw_aleph_result)

      Skala::GetUserResult.new(
        email_address: fields["bor_info"]["z304"]["z304_email_address"],
        expiry_date: Date.strptime(fields["bor_info"]["z305"]["z305_expiry_date"], "%d/%m/%Y"),
        username: username,
        id: fields["bor_info"]["z303"]["z303_id"],
        first_name: fields["bor_info"]["z303"]["z303_name"].split(",").last.strip,
        last_name: fields["bor_info"]["z303"]["z303_name"].split(",").first.strip,

        fields: fields
      )
    end
  end

end
