module Ils::Adapters
  class AlephAdapter
    class RecordFactory

      def self.build(xml)
        self.new.build(xml)
      end

      def build(xml)
        Ils::Record.new(
          id: get_id(xml),
          signature: get_signature(xml),
          title: get_title(xml),
          author: get_author(xml),
          year: get_year(xml)
        )
      end

    private

      def get_id(node)
        node.at_xpath("z13/z13-doc-number")&.text
      end

      def get_signature(node)
        node.at_xpath("z13/z13-call-no")&.text
      end

      def get_title(node)
        node.at_xpath("z13/z13-title")&.text
      end

      def get_author(node)
        node.at_xpath("z13/z13-author")&.text
          &.gsub(/\(.+\)[0-9X]+/, "")
          &.gsub(/\d{4}-/, "")
          &.gsub(/\d{4}/, "")
          &.strip
      end

      def get_year(node)
        node.at_xpath("z13/z13-year")&.text
      end

    end
  end
end
