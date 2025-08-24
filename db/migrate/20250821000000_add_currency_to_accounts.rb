class AddCurrencyToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :accounts, :currency, :string, null: false, default: "USD"
  end
end



