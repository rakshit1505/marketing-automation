class Deal < ApplicationRecord
  belongs_to :potential, optional: true
  has_many :statuses, as: :statusable
  has_one :lead, through: :potential
end
