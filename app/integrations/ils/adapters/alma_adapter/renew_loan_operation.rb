module Ils::Adapters
  class AlmaAdapter
    class RenewLoanOperation < Operation

      def call(user_id, loan_id)
        adapter.api.post("users/#{user_id}/loans/#{loan_id}", params: {
          op: "renew"
        })

        Ils::RenewLoanResult.new(loan_id: loan_id, success: true)
      rescue AlmaApi::Error => e
        Ils::RenewLoanResult.new(loan_id: loan_id, success: false)
      end

    end
  end
end
