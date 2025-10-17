module Api
  module V1
    class AccountsController < BaseController
      before_action :set_account, only: [:show, :update, :destroy, :statement]

      def index
        accounts = current_user.accounts
        render_success(accounts: accounts)
      end

      def show
        render_success(account: @account)
      end

      def create
        account = current_user.accounts.create!(account_params)
        render_success({ account: account }, :created)
      end

      def update
        @account.update!(account_params)
        render_success(account: @account)
      end

      def destroy
        @account.destroy
        head :no_content
      end

      def statement
        start_date = Date.parse(params[:start_date])
        end_date = Date.parse(params[:end_date])
        
        statement_data = @account.statement(start_date, end_date)
        render_success(statement: statement_data)
      end

      private

      def set_account
        @account = current_user.accounts.find(params[:id])
      end

      def account_params
        params.require(:account).permit(
          :name,
          :account_type,
          :balance,
          :classification,
          :active,
          :currency
        )
      end
    end
  end
end
