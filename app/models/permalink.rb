class Permalink < ApplicationRecord

  validates :key, presence: true, format: { with: /\A[a-zA-Z0-9]+\z/ } # unique case is handled in controller
  validates :scope, presence: true
  validates :search_request, presence: true

  def to_param
    key
  end

end
