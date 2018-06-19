require "skala/adapter/update_user"
require_relative "../aleph_adapter"
require_relative "./resolve_user"

class Skala::AlephAdapter::UpdateUser < Skala::Adapter::UpdateUser
  include parent::ResolveUser

  def call(type:, user:, new_password:nil, new_email_address:nil)
    case type
    when "password" then update_password(user.ilsuserid, user.ilsusername, new_password)
    when "email" then update_email_address(user.ilsuserid, new_email_address)
    else ArgumentError.new("Unknown type '#{type}'")
    end
  end

  private

  def update_email_address(userid, new_email_address)
    raw_aleph_responses = ["01", "02"].map do |_z304_address_type|
      adapter.x_services.post(
        op: :update_bor,
        update_flag: "Y",
        library: adapter.default_user_library,
        xml_full_req: <<-XML.strip_heredoc
          <?xml version="1.0"?>
          <p-file-20>
            <patron-record>
              <z303>
                <match-id-type>00</match-id-type>
                <match-id>#{userid}</match-id>
                <record-action>X</record-action>
              </z303>
              <z304>
                <record-action>U</record-action>
                <z304-id>#{userid}</z304-id>
                <z304-address-type>#{_z304_address_type}</z304-address-type>
                <z304-sequence>01</z304-sequence>
                <z304-email-address>#{new_email_address}</z304-email-address>
              </z304>
            </patron-record>
          </p-file-20>
        XML
      )
    end

    if raw_aleph_responses.none? { |_raw_aleph_response| _raw_aleph_response[/Succeeded to REWRITE table z304/] }
      return false
    else
      return true
    end
  end

  def update_password(userid, username, new_password)
    # we have to change the password for all ids
    raw_aleph_responses = [[userid, "00"], [username, "01"]].map do |_element|
      _user_id = _element[0]
      _id_type = _element[1]

      raw_aleph_response = adapter.x_services.post(
        op: :update_bor,
        update_flag: "Y",
        library: adapter.default_user_library,
        xml_full_req: <<-XML.strip_heredoc
          <?xml version="1.0"?>
          <p-file-20>
            <patron-record>
              <z303>
                <match-id-type>#{_id_type}</match-id-type>
                <match-id>#{_user_id}</match-id>
                <record-action>X</record-action>
              </z303>
              <z308>
                <record-action>U</record-action>
                <z308-key-type>#{_id_type}</z308-key-type>
                <z308-key-data>#{_user_id}</z308-key-data>
                <z308-verification>#{new_password}</z308-verification>
              </z308>
            </patron-record>
          </p-file-20>
        XML
      )
    end

    if raw_aleph_responses.none? { |_raw_aleph_response| _raw_aleph_response[/Succeeded to REWRITE table z308/] }
      false
    else
      true
    end
  end
end
