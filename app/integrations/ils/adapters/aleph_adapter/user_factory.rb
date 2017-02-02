module Ils::Adapters
  class AlephAdapter
    class UserFactory

      def self.build(xml)
        self.new.build(xml)
      end

      def build(xml)
        Ils::User.new(
          id: get_id(xml),
          firstname: get_firstname_lastname(xml)[0],
          lastname: get_firstname_lastname(xml)[1],
          email: get_email(xml),
          note: get_note(xml)
        )
      end

    private

      def get_id(xml)
        xml.at_xpath("z303/z303-id")&.text
      end

      def get_email(xml)
        xml.at_xpath("z304/z304-email-address")&.text
      end

      def get_note(xml)
        xml.at_xpath("z305/z305-note")&.text
      end

      def get_firstname_lastname(xml)
        # Format in z303-name is LASTNAME, FIRSTNAME
        fullname = xml.at_xpath("z303/z303-name")&.text || ""

        firstname = xml.at_xpath("z303/z303-first-name")&.text.presence || fullname.split(",").last&.strip.presence
        lastname  = xml.at_xpath("z303/z303-last-name")&.text.presence  || fullname.split(",").first&.strip.presence

        if firstname == lastname
          [nil, lastname]
        else
          [firstname, lastname]
        end
      end

    end
  end
end
