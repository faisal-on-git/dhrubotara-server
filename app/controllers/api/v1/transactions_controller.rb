module Api
  module V1
    class TransactionsController < ApplicationController
      before_action :set_transaction, only: [:show, :update, :destroy]

      def index
        @transactions = Transaction.includes(:account).all
        render json: @transactions
      end

      def show
        render json: @transaction
      end

      def create
        @transaction = Transaction.new(transaction_params)

        if @transaction.save
          render json: @transaction, status: :created
        else
          render json: @transaction.errors, status: :unprocessable_entity
        end
      end

      def update
        if @transaction.update(transaction_params)
          render json: @transaction
        else
          render json: @transaction.errors, status: :unprocessable_entity
        end
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
        params.require(:transaction).permit(:date, :description, :amount, :transaction_type, :category, :account_id)
      end
    end
  end
end
