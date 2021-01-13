class Order
  include ActiveModel::Model

  attr_accessor :signature
  attr_accessor :is_mono_order
  attr_accessor :title
  attr_accessor :loan_status
  attr_accessor :year
  attr_accessor :volume
  attr_accessor :user
  attr_accessor :created_at
  attr_accessor :barcode

  validates :signature, presence: true
  validates :year, presence: true, if: Proc.new { |o| o.is_mono_order == false }
  validates :volume, presence: true, if: Proc.new { |o| o.is_mono_order == false }
  validates :user, presence: true
  validates :created_at, presence: true

  def persisted?
    false
  end

  def is_mono_order=(value)
    @is_mono_order = ActiveModel::Type::Boolean.new.cast(value)
  end

end
