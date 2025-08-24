class Account < ApplicationRecord
  has_many :transactions, dependent: :destroy
  has_many :outgoing_transfers, class_name: 'Transaction', foreign_key: 'account_id'
  has_many :incoming_transfers, class_name: 'Transaction', foreign_key: 'transfer_account_id'

  validates :name, presence: true
  validates :account_type, inclusion: { in: %w[checking savings credit_card loan investment cash] }, allow_blank: true
  validates :balance, presence: true, numericality: true
  validates :category, presence: true, inclusion: { in: %w[asset liability other] }
  validates :currency, presence: true

  scope :assets, -> { where(category: 'asset') }
  scope :liabilities, -> { where(category: 'liability') }
  scope :active, -> { where(active: true) }

  def update_balance(amount)
    multiplier = category == 'liability' ? -1 : 1
    self.balance += (amount * multiplier)
    save
  end

  def net_worth_impact
    category == 'liability' ? -balance : balance
  end

  def all_transactions
    Transaction.where('account_id = ? OR transfer_account_id = ?', id, id)
  end

  def statement(start_date, end_date)
    {
      starting_balance: balance_at(start_date),
      ending_balance: balance_at(end_date),
      transactions: all_transactions.for_period(start_date, end_date),
      period_net_change: net_change_for_period(start_date, end_date)
    }
  end

  private

  def balance_at(date)
    return balance if date >= Date.current
    
    transactions_after = all_transactions.where('date > ?', date)
    current_balance = balance
    
    transactions_after.each do |t|
      if t.account_id == id
        current_balance -= t.amount
      else
        current_balance += t.amount
      end
    end
    
    current_balance
  end

  def net_change_for_period(start_date, end_date)
    balance_at(end_date) - balance_at(start_date)
  end
end
