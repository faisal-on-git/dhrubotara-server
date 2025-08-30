class AddUniqueBudgetIndex < ActiveRecord::Migration[7.1]
  def up
    # Remove duplicate budget entries, keeping the lowest id for each category and start_date
    execute <<-SQL.squish
      DELETE FROM budgets b1
      USING budgets b2
      WHERE b1.id > b2.id
        AND b1.category_id = b2.category_id
        AND b1.start_date = b2.start_date;
    SQL

    add_index :budgets, [:category_id, :start_date], unique: true, name: "index_budgets_on_category_and_start"
  end

  def down
    remove_index :budgets, name: "index_budgets_on_category_and_start"
  end
end
