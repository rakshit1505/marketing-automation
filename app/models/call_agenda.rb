class CallAgenda < ApplicationRecord

  belongs_to :call_information, optional: true
end
