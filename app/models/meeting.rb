class Meeting < ApplicationRecord

  belongs_to :user, optional: true
end
