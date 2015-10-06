json.hits do
  json.total @total_hits
  json.hits @hits do |hit|
    json.(hit,
      :classification,
      :created,
      :creator,
      :description,
      :edition,
      :format,
      :id,
      :identifier,
      :is_part_of,
      :isbn,
      :issn,
      :language,
      :medium,
      :place_of_publication,
      :publisher,
      :signature,
      :subject,
      :title,
      :type
    )
  end
end
