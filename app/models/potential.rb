class Potential < ApplicationRecord
  belongs_to :lead, optional: true
  belongs_to :company, optional: true
  belongs_to :user, optional: true
  has_one :deal, dependent: :destroy
  has_many :statuses, as: :statusable

  scope :search_potential, -> (potential) {
    if potential.present?
      query_1 = where("lower(leads.first_name) LIKE :potential OR lower(leads.last_name) LIKE :potential OR lower(leads.email) LIKE :potential OR leads.phone_number LIKE :potential", :potential => "%#{potential.downcase}%")
                .or(self.where('lower(potentials.amount) LIKE :potential', :potential => "%#{potential.downcase}%")).joins(:lead)
      query_2 = where("lower(users.first_name) LIKE :potential OR lower(users.last_name) LIKE :potential", :potential => "%#{potential.downcase}%").joins(:user)
      query_3 = where("lower(companies.name) LIKE :potential", :potential => "%#{potential.downcase}%").joins(:company)
      ids = query_1.ids + query_2.ids + query_3.ids
      where(id: ids.uniq)
    else
      self.all
    end
    }
end
