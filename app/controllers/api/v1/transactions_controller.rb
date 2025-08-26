module Api
  module V1
    class TransactionsController < BaseController
      before_action :set_transaction, only: [:show, :update, :destroy]

      def index
        transactions = Transaction.includes(:account).all
        
        transactions = transactions.where(account_id: params[:account_id]) if params[:account_id]
        transactions = transactions.where(transaction_type: params[:type]) if params[:type]
        transactions = transactions.where(category: params[:category]) if params[:category]
        
        if params[:start_date] && params[:end_date]
          transactions = transactions.for_period(
            Date.parse(params[:start_date]),
            Date.parse(params[:end_date])
          )
        end

        serialized = TransactionSerializer.new(transactions).serializable_hash[:data].map { |d| d[:attributes] }
        render_success(transactions: serialized)
      end

      def show
        render_success(transaction: TransactionSerializer.new(@transaction).serializable_hash[:data][:attributes])
      end

      def create
        transaction = Transaction.create!(transaction_params)
        render_success({ transaction: TransactionSerializer.new(transaction).serializable_hash[:data][:attributes] }, :created)
      end

      def update
        @transaction.update!(transaction_params)
        render_success(transaction: TransactionSerializer.new(@transaction).serializable_hash[:data][:attributes])
      end

      def destroy
        @transaction.destroy
        head :no_content
      end

      private

      def set_transaction
        @transaction = Transaction.find(params[:id])
      end

      def transaction_params
        params.require(:transaction).permit(
          :date,
          :description,
          :amount,
          :transaction_type,
          :category,
          :category_id,
          :account_id,
          :transfer_account_id,
          :budget_id
        )
      end
    end
  end
end
