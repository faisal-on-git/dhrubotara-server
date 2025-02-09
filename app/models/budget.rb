class Budget < ApplicationRecord
  validates :category, presence: true, uniqueness: true
  validates :budgeted, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :spent, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def remaining
    budgeted - spent
  end

  def percentage_used
    (spent / budgeted * 100).round(2)
  end
end
