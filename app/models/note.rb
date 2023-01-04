class Note < ApplicationRecord

  belongs_to :lead, optional: true
  belongs_to :user, optional: true
end
