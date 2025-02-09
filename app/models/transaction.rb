class Transaction < ApplicationRecord
  belongs_to :account

  validates :date, presence: true
  validates :description, presence: true
  validates :amount, presence: true, numericality: true
  validates :transaction_type, presence: true, inclusion: { in: %w[income expense] }
  validates :category, presence: true

  after_create :update_account_balance
  before_destroy :revert_account_balance

  private

  def update_account_balance
    account.update_balance(amount)
  end

  def revert_account_balance
    account.update_balance(-amount)
  end
end
