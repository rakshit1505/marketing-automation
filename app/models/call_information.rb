class CallInformation < ApplicationRecord

  belongs_to :call_type, optional: true
  has_one :call_agenda, dependent: :destroy
  belongs_to :lead, optional: true
  belongs_to :user, optional: true
end
