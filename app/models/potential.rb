class Potential < ApplicationRecord
  belongs_to :lead, optional: true
  has_one :deal, dependent: :destroy
  has_many :statuses, as: :statusable
  has_many :audits, as: :auditable 
  attr_accessor :current
end
