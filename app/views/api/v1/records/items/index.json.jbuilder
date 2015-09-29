json.array! @items do |item|
  %w(id availability description due_date status signature).each do |field_name|
    json.set!(field_name, item.send(field_name))
  end
end
