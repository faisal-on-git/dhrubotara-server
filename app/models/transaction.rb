class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :transfer_account, class_name: 'Account', optional: true
  belongs_to :budget, optional: true

  validates :date, presence: true
  validates :description, presence: true
  validates :amount, presence: true, numericality: true
  validates :transaction_type, presence: true, inclusion: { in: %w[income expense transfer] }
  validates :category, presence: true
  validate :validate_transfer_account

  after_create :update_account_balances
  before_destroy :revert_account_balances

  scope :income, -> { where(transaction_type: 'income') }
  scope :expense, -> { where(transaction_type: 'expense') }
  scope :transfers, -> { where(transaction_type: 'transfer') }
  scope :for_period, ->(start_date, end_date) { where(date: start_date..end_date) }

  private

  def validate_transfer_account
    if transaction_type == 'transfer'
      errors.add(:transfer_account, "must be present for transfer transactions") if transfer_account.nil?
      errors.add(:transfer_account, "cannot be the same as the source account") if transfer_account == account
    end
  end

  def update_account_balances
    case transaction_type
    when 'income', 'expense'
      account.update_balance(amount)
    when 'transfer'
      account.update_balance(-amount)
      transfer_account.update_balance(amount)
    end
  end

  def revert_account_balances
    case transaction_type
    when 'income', 'expense'
      account.update_balance(-amount)
    when 'transfer'
      account.update_balance(amount)
      transfer_account.update_balance(-amount)
    end
  end
end
