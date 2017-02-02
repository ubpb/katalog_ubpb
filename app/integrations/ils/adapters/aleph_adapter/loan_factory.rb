module Ils::Adapters
  class AlephAdapter
    class LoanFactory

      def self.build_loans(xml)
        self.new.build_loans(xml)
      end

      def build_loans(xml)
        xml.xpath("//loan").map do |node|
          Ils::Loan.new(
            id: get_id(node),
            loan_date: get_loan_date(node),
            due_date: get_due_date(node),
            returned_date: get_returned_date(node),
            renewable: get_renewable(node),
            ill: get_ill(node),
            record: AlephAdapter::RecordFactory.build(node)
          )
        end
      end

    private

      def get_id(node)
        node["href"][/[^\/]+\Z/][/\A[^?]+/]
      end

      def get_loan_date(node)
        date = node.at_xpath("z36/z36-loan-date")&.text || node.at_xpath("z36h/z36h-loan-date")&.text
        Date.strptime(date, "%Y%m%d") if date
      end

      def get_due_date(node)
        date = node.at_xpath("z36/z36-due-date")&.text || node.at_xpath("z36h/z36h-due-date")&.text
        Date.strptime(date, "%Y%m%d") if date
      end

      def get_returned_date(node)
        date = node.at_xpath("z36h/z36h-returned-date")&.text
        Date.strptime(date, "%Y%m%d") if date
      end

      def get_renewable(node)
        due_date = get_due_date(node)
        node["renew"] == "Y" && (due_date - Date.today <= 30)
      end

      def get_ill(node)
        node.at_xpath("z30/z30-collection-code")&.text == "ILL" ||
        node.at_xpath("z36h/z36h-process-status")&.text == "IL"
      end

    end
  end
end
