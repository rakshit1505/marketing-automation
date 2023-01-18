class Lead < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :company
  belongs_to :lead_source, optional: true
  belongs_to :lead_rating, optional: true
  has_one :potential, dependent: :destroy
  # has_one :deal, through: :potential
  has_one :lead_address, dependent: :destroy
  has_many :tasks
  has_many :statuses, as: :statusable
  has_many :audits, as: :auditable
  attr_accessor :current

  validates :first_name, :last_name, :company_id, presence: true

  scope :search_lead, -> (lead) {
    if lead.present?
      query_1 = where("lower(lead_sources.name) LIKE :lead", :lead => "%#{lead.downcase}%")
                .or(self.where('lower(leads.first_name) LIKE :lead OR lower(leads.last_name) LIKE :lead OR lower(leads.email) LIKE :lead OR leads.phone_number LIKE :lead',
                :lead => "%#{lead.downcase}%")).joins(:lead_source)
      query_2 = where("lower(users.first_name) LIKE :lead OR lower(users.last_name) LIKE :lead", :lead => "%#{lead.downcase}%").joins(:user)
      query_3 = where("lower(companies.name) LIKE :lead", :lead => "%#{lead.downcase}%").joins(:company)
      ids = query_1.ids + query_2.ids + query_3.ids
      where(id: ids.uniq)
    else
      self.all
    end
    }

  scope :my_leads, -> (user_id) { user_id.present? ? where(user_id: user_id) : all }

  def self.search(index_params)
    search_lead(index_params[:lead]).
    my_leads(index_params[:user_id])
  end

end
