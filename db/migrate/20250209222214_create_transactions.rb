class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.date :date
      t.string :description
      t.decimal :amount
      t.string :transaction_type
      t.string :category
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end
  end
end
