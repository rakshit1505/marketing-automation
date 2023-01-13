class Pipeline < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :lead_source, optional: true

  validates :account_name, presence: true

end
