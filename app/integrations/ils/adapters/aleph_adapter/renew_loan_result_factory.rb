module Ils::Adapters
  class AlephAdapter
    class RenewLoanResultFactory

      def self.build(node)
        self.new.build(node)
      end

      def build(node)
        Ils::RenewLoanResult.new(
          id: get_id(node),
          success: get_success(node),
          new_due_date: get_new_due_date(node)
        )
      end

    private

      def get_id(node)
        node["id"]
      end

      def get_success(node)
        node.at_xpath("status-code")&.text == "Y"
      end

      def get_new_due_date(node)
        date = node.at_xpath("new-due-date")&.text
        Date.strptime(date, "%Y%m%d") if date
      end

    end
  end
end
