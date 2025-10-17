class BudgetCategory < ApplicationRecord
  belongs_to :budget
  belongs_to :category

  validates :budgeted_spend, numericality: { greater_than_or_equal_to: 0 }

  # Sum of expenses for this category within the budget period
  def spent
    Transaction.expense
               .where(category_id: category_id, date: budget.start_date..budget.end_date)
               .sum(:amount)
  end

  def remaining
    budgeted_spend - spent
  end
end
