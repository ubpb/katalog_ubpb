module Ils::Adapters
  class AlephAdapter
    class GetItemsOperation < Operation

      def call(record_id)
        unless record_id.starts_with?(adapter.options[:document_base])
          record_id = "#{adapter.options[:document_base]}#{record_id}"
        end

        response      = adapter.rest_api.record(record_id).items.get({view: :full})
        xml           = Nokogiri::XML(response)
        error_code    = xml.at_xpath("//reply-code")&.text
        error_message = xml.at_xpath("//reply-text")&.text

        if error_code == "0000"
          item_nodes = xml.xpath("//item")
          items = item_nodes.map do |node|
            ItemFactory.build(node, item_count: item_nodes.count)
          end

          items = filter_items(items)
          #items = sort_items(items)
        else
          adapter.logger.error("GetItems failed! Error code: #{error_code}. Message: #{error_message}")
          []
        end
      end

    private

      def filter_items(items)
        # reject all items which end with "-..."
        items.reject { |item| item.signature.present? && item.signature[/-\.\.\.\Z/] }
      end

      # def sort_items(items)
      #   items.sort do |x, y|
      #     if x.signature.blank?
      #       0 <=> -1
      #     elsif y.signature.blank?
      #       -1 <=> 0
      #     else
      #       (x.signature.split("+")[1] || 0).to_i <=> (y.signature.split("+")[1] || 0).to_i
      #     end
      #   end
      # end

    end
  end
end
