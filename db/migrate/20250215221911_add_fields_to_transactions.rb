class AddFieldsToTransactions < ActiveRecord::Migration[7.1]
  def change
    add_reference :transactions, :transfer_account, foreign_key: { to_table: :accounts }, null: true
    add_reference :transactions, :budget, foreign_key: true, null: true
  end
end
