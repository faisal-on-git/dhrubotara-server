class AddCategoryRefs < ActiveRecord::Migration[7.1]
  def change
    add_reference :transactions, :category, foreign_key: true
    add_reference :budgets, :category, foreign_key: true
  end
end
