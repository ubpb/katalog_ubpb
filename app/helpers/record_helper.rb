module RecordHelper

  def is_journal?(record)
    record.media_type == "journal"
  end

  def is_online_resource?(record)
    record.carrier_type == "online_resource"
  end

  def is_superorder?(record)
    record.is_superorder == true
  end

  def is_secondary_form?(record)
    record.is_secondary_form == true
  end

end
