module RecordHelper

  def is_journal?(record)
    record.try(:media_type) == "journal"
  end

  def is_newspaper?(record)
    record.try(:media_type) == "newspaper"
  end

  def is_online_resource?(record)
    record.try(:carrier_type) == "online_resource"
  end

  def is_superorder?(record)
    record.try(:is_superorder) == true
  end

  def is_secondary_form?(record)
    record.try(:is_secondary_form) == true
  end

end
