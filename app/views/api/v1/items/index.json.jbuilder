# this is more explicit than it had to be, but it underlines the facet
# that the response is not tied to the internal data structures
@items.each_pair do |record_id, items|
  json.set! record_id do
    json.array! items do |item|
      json.loan_status item["loan_status"]
      json.loanable item["loanable"]
      json.only_short_loanable item["only_short_loanable"]
      json.present item["present"]
      json.signature item["signature"]
      json.status item["status"]
    end
  end
end
