class Lead < ApplicationRecord

  belongs_to :lead_source, optional: true
  belongs_to :lead_status, optional: true
  belongs_to :lead_rating, optional: true
  has_one :lead_address, dependent: :destroy
  has_many :tasks, dependent: :destroy
end
