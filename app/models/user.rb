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
end
