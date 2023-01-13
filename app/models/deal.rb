class Deal < ApplicationRecord
  belongs_to :potential, optional: true
  belongs_to :user, optional: true
  has_many :statuses, as: :statusable
  has_one :lead, through: :potential


  scope :search_deal, -> (deal) { deal.present? ? where("lower(users.first_name) LIKE :deal OR lower(users.last_name) LIKE :deal", :deal => "%#{deal.downcase}%")
                                  .or(where('deals.sign_off_date = :deal OR lower(deals.value) LIKE :deal OR lower(deals.term) LIKE :deal OR lower(deals.tenure) LIKE :deal',
                                  :deal => "%#{deal.downcase}%")).joins(:user) : all

    }
end
