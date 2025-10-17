class Account < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :destroy

  enum classification: { asset: "asset", liability: "liability" }

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :classification, inclusion: { in: classifications.keys }
  validates :balance, numericality: true
  validates :currency, presence: true

  scope :active, -> { where(active: true) }

  # For dashboard metrics
  scope :assets, -> { where(classification: :asset) }
  scope :liabilities, -> { where(classification: :liability) }

  def update_balance(delta)
    # delta is always positive from Transaction.amount
    multiplier = liability? ? -1 : 1
    self.balance += delta * multiplier
    save!
  end

  def net_worth_value
    liability? ? -balance : balance
  end

  alias_method :net_worth_impact, :net_worth_value
end
