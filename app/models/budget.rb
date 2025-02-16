class Budget < ApplicationRecord
  has_many :transactions
  
  validates :category, presence: true
  validates :budgeted, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :spent, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date

  scope :active, -> { where('end_date >= ?', Date.current) }
  scope :for_month, ->(date) { where('start_date <= ? AND end_date >= ?', date.end_of_month, date.beginning_of_month) }

  def remaining
    budgeted - spent
  end

  def percentage_used
    return 0 if budgeted.zero?
    (spent / budgeted * 100).round(2)
  end

  def status
    percentage = percentage_used
    if percentage >= 100
      'exceeded'
    elsif percentage >= 80
      'warning'
    else
      'good'
    end
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
    
    if end_date < start_date
      errors.add(:end_date, "must be after start date")
    end
  end
end
