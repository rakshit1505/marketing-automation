class Lead < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :lead_source, optional: true
  belongs_to :lead_rating, optional: true
  has_one :potential, dependent: :destroy
  # has_one :deal, through: :potential
  has_one :lead_address, dependent: :destroy
  has_many :tasks
  has_many :statuses, as: :statusable

  validates :first_name, :last_name, presence: true
end
