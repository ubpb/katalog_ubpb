class Skala::GetUserResult
  include Virtus.model

  attribute :id,                      String
  attribute :username,                String
  attribute :first_name,              String
  attribute :last_name,               String
  attribute :email_address,           String
  attribute :cash_balance,            Float
  attribute :expiry_date,             Date
  attribute :number_of_hold_requests, Integer
  attribute :number_of_loans,         Integer

  attribute :fields
end
