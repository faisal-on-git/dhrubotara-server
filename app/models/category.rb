class Category < ApplicationRecord
  belongs_to :user
  belongs_to :parent, class_name: "Category", optional: true
  has_many   :children, class_name: "Category", foreign_key: :parent_id, dependent: :destroy
  has_many   :transactions, dependent: :nullify
  has_many   :budget_categories, dependent: :destroy

  enum classification: { expense: "expense", income: "income" }

  validates :name, presence: true, uniqueness: { scope: :user_id }
  validates :classification, inclusion: { in: classifications.keys }
end
