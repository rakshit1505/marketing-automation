class LeadAddress < ApplicationRecord

  belongs_to :lead, optional: true
end
