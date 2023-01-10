class Status < ApplicationRecord
  belongs_to :statusable, polymorphic: true, optional: true
end
