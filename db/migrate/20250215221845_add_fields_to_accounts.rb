class AddFieldsToAccounts < ActiveRecord::Migration[7.1]
  def change
    add_column :accounts, :category, :string, null: false, default: 'asset'
    add_column :accounts, :active, :boolean, null: false, default: true
  end
end
