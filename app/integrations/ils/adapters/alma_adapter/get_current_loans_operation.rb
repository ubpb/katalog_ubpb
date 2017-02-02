module Ils::Adapters
  class AlmaAdapter
    class GetCurrentLoansOperation < Operation

      LIMIT = 1

      def call(user_id)
        offset = 0
        loans  = []

        response = get_loans(user_id, offset: offset, limit: LIMIT)
        loans << response["item_loan"]

        total_record_count = response["total_record_count"] || 0

        if LIMIT < total_record_count
          while offset < total_record_count
            offset = offset + LIMIT
            response = get_loans(user_id, offset: offset, limit: LIMIT)
            loans << response["item_loan"]
          end
        end


        puts loans
      end

    private

      def get_loans(user_id, offset:, limit:)
        adapter.api.get("users/#{user_id}/loans", params: {
          expand: "renewable",
          order_by: "due_date",
          limit: limit,
          offset: offset
        })
      end

    end
  end
end
