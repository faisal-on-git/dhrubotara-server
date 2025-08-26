class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  # Associations
  has_many :categories, dependent: :destroy
  has_many :accounts, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :budgets, dependent: :destroy

  def jwt_payload
    super
  end
end
