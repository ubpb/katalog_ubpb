require_relative "../adapter"

class Skala::Adapter::GetUserTransactions < Skala::Adapter::Operation
  require_relative "./get_user_transactions/result"
end
