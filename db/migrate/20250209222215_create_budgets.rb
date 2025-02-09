class CreateBudgets < ActiveRecord::Migration[7.1]
  def change
    create_table :budgets do |t|
      t.string :category
      t.decimal :budgeted
      t.decimal :spent

      t.timestamps
    end
  end
end
