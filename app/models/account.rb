class Account < ApplicationRecord
  has_many :transactions, dependent: :destroy

  validates :name, presence: true
  validates :account_type, presence: true
  validates :balance, presence: true, numericality: true

  def update_balance(amount)
    self.balance += amount
    save
  end
end
