class Transaction < ApplicationRecord
  belongs_to :account
  belongs_to :transfer_account, class_name: 'Account', optional: true
  belongs_to :budget, optional: true
  belongs_to :category, optional: true

  validates :date, presence: true
  validates :description, presence: true
  validates :amount, presence: true, numericality: true
  validates :transaction_type, presence: true, inclusion: { in: %w[income expense transfer] }
  validates :category, presence: true, if: -> { category_id.nil? }
  validate :validate_transfer_account

  after_create :update_account_balances
  after_create :apply_budget_impact
  before_destroy :revert_account_balances
  after_destroy :revert_budget_impact
  before_update :handle_budget_change

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

  # Budget helpers
  def apply_budget_impact
    return unless budget_id.present?

    if transaction_type == 'expense'
      budget.increment!(:spent, amount.abs)
    elsif transaction_type == 'income'
      budget.decrement!(:spent, amount.abs)
    end
  end

  def revert_budget_impact
    return unless budget_id.present?

    if transaction_type == 'expense'
      budget.decrement!(:spent, amount.abs)
    elsif transaction_type == 'income'
      budget.increment!(:spent, amount.abs)
    end
  end

  def handle_budget_change
    return unless budget_id_changed?

    # revert from old budget
    if budget_id_was.present?
      old_budget = Budget.find_by(id: budget_id_was)
      if old_budget
        delta = transaction_type == 'expense' ? -amount_was : amount_was
        old_budget.increment!(:spent, delta.abs)
      end
    end

    # apply to new budget after save via after_commit hook
  end
end
