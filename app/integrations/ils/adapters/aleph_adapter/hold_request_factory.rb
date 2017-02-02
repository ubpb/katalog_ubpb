module Ils::Adapters
  class AlephAdapter
    class HoldRequestFactory

      def self.build(node)
        self.new.build(node)
      end

      def build(node)
        Ils::HoldRequest.new(
          id: get_id(node),
          status: get_status(node),
          deleteable: get_deleteable(node),
          begin_request_date: get_begin_request_date(node),
          end_request_date: get_end_request_date(node),
          begin_hold_date: get_begin_hold_date(node),
          end_hold_date: get_end_hold_date(node),
          queue_position: get_queue_position(node),
          record: AlephAdapter::RecordFactory.build(node)
        )
      end

    private

      def get_id(node)
        node["href"][/[^\/]+\Z/][/\A[^?]+/]
      end

      def get_status(node)
        case node.at_xpath("z37/z37-status")&.text
          when /\Awaiting in queue/i then :requested
          when /\As/i                then :on_hold
          when /\Ain process/i       then :in_process
        end
      end

      def get_deleteable(node)
        node["delete"] == "Y"
      end

      def get_begin_request_date(node)
        date = node.at_xpath("z37/z37-request-date")&.text
        Date.strptime(date, "%Y%m%d") if date
      end

      def get_end_request_date(node)
        date = node.at_xpath("z37/z37-end-request-date")&.text
        Date.strptime(date, "%Y%m%d") if date
      end

      def get_begin_hold_date(node)
        date = node.at_xpath("z37/z37-hold-date")&.text
        Date.strptime(date, "%Y%m%d") if date && date != "00000000"
      end

      def get_end_hold_date(node)
        date = node.at_xpath("z37/z37-end-hold-date")&.text
        Date.strptime(date, "%Y%m%d") if date && date != "00000000"
      end

      def get_queue_position(node)
        node.at_xpath("status")&.text.presence.try(:[], /Waiting in position \d+/).try(:[], /\d+/).try(:to_i)
      end

    end
  end
end
