class Audit < ApplicationRecord
	  belongs_to :auditable, polymorphic: true, optional: true
end
