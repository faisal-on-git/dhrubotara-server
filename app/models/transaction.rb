class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :account
  belongs_to :transfer_account, class_name: 'Account', optional: true
  belongs_to :category, optional: true
  belongs_to :budget_category, optional: true

  enum transaction_type: { income: 'income', expense: 'expense', transfer: 'transfer' }

  validates :date, :amount, :transaction_type, presence: true
  validates :amount, numericality: { greater_than: 0 }
  validates :category, presence: true, if: -> { expense? }
  validate  :transfer_account_validations

  after_create  :apply_account_changes
  after_destroy :revert_account_changes

  scope :for_period, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :expense, -> { where(transaction_type: 'expense') }
  scope :income,  -> { where(transaction_type: 'income') }

  private

  def transfer_account_validations
    return unless transfer?
    errors.add(:transfer_account, 'must be present for transfer') if transfer_account.nil?
    errors.add(:transfer_account, 'cannot be same as source') if transfer_account == account
  end

  def apply_account_changes
    case transaction_type
    when 'income'
      account.update_balance(amount)
    when 'expense'
      account.update_balance(-amount)
    when 'transfer'
      account.update_balance(-amount)
      transfer_account.update_balance(amount)
    end
  end

  def revert_account_changes
    case transaction_type
    when 'income'
      account.update_balance(-amount)
    when 'expense'
      account.update_balance(amount)
    when 'transfer'
      account.update_balance(amount)
      transfer_account.update_balance(-amount)
    end
  end
end
