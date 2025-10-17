class InitialFinancialSchema < ActiveRecord::Migration[7.1]
  def change
    # Clean slate when existing tables are present (for redevelopment phase)
    drop_table :transactions, if_exists: true
    drop_table :budget_categories, if_exists: true
    drop_table :budgets, if_exists: true
    drop_table :categories, if_exists: true
    drop_table :accounts, if_exists: true

    # Accounts table
    create_table :accounts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :account_type
      t.string :classification, null: false, default: "asset" # asset | liability
      t.decimal :balance, precision: 15, scale: 2, null: false, default: 0
      t.string :currency, null: false, default: "USD"
      t.boolean :active, null: false, default: true
      t.timestamps
    end
    add_index :accounts, [:user_id, :name], unique: true

    # Categories table
    create_table :categories do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :classification, null: false, default: "expense" # expense | income
      t.string :icon
      t.string :icon_color
      t.references :parent, foreign_key: { to_table: :categories }
      t.timestamps
    end
    add_index :categories, [:user_id, :name], unique: true

    # Budgets table
    create_table :budgets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.string :currency, null: false, default: "USD"
      t.timestamps
    end

    # BudgetCategories join table
    create_table :budget_categories do |t|
      t.references :budget, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.decimal :budgeted_spend, precision: 15, scale: 2, null: false
      t.timestamps
    end
    add_index :budget_categories, [:budget_id, :category_id], unique: true

    # Transactions table
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false
      t.string :description
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.string :transaction_type, null: false # income | expense | transfer
      t.references :account, null: false, foreign_key: true
      t.references :transfer_account, foreign_key: { to_table: :accounts }
      t.references :category, foreign_key: true
      t.references :budget_category, foreign_key: true
      t.timestamps
    end
    add_index :transactions, :date
  end
end
