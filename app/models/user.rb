class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  include Devise::JWT::RevocationStrategies::JTIMatcher
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  belongs_to :company, optional: true
  belongs_to :role, optional: true
  belongs_to :department, optional: true
  has_many :meetings, dependent: :destroy
  has_many :tasks
  has_one :manage_data

  validates :first_name, :last_name, presence: true

 # callbacks
  before_save :set_full_name


  def set_full_name
    self.full_name = self.first_name.to_s + " " + self.last_name.to_s
  end
end
