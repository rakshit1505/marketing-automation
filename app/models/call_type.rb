class CallType < ApplicationRecord

  has_many :call_informations, dependent: :destroy
end
