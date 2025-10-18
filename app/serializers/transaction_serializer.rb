class TransactionSerializer
  include JSONAPI::Serializer

  attributes :id,
             :date,
             :description,
             :amount,
             :transaction_type,
             :category,
             :account_id,
             :transfer_account_id,
             :budget_category_id,
             :created_at,
             :updated_at

  attribute :account_name do |object|
    object.account&.name
  end
end
