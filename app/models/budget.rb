class Budget < ApplicationRecord
  belongs_to :user
  has_many :budget_categories, dependent: :destroy
  accepts_nested_attributes_for :budget_categories, allow_destroy: true

  validates :start_date, :end_date, presence: true
  validate :end_date_after_start_date

  scope :active, -> { where('end_date >= ?', Date.current) }

  def period
    start_date..end_date
  end

  # Aggregate helpers for new schema
  def total_budgeted
    budget_categories.sum(:budgeted_spend)
  end

  def spent
    Transaction.expense
               .where(category_id: budget_categories.pluck(:category_id), date: period)
               .sum(:amount)
  end

  def remaining
    total_budgeted - spent
  end

  def percentage_used
    return 0 if total_budgeted.zero?
    (spent / total_budgeted * 100).round(2)
  end

  def status
    pct = percentage_used
    return 'exceeded' if pct >= 100
    return 'warning'  if pct >= 80
    'good'
  end

  def days_remaining
    [0, (end_date - Date.current).to_i].max
  end

  def daily_budget
    remaining / [1, days_remaining].max
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?
    errors.add(:end_date, 'must be after start date') if end_date < start_date
  end
end
