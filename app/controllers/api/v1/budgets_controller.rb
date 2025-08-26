module Api
  module V1
    class BudgetsController < BaseController
      before_action :set_budget, only: [:show, :update, :destroy, :progress]

      def index
        budgets = Budget.all
        budgets = budgets.active if params[:active].present?
        
        if params[:date]
          date = Date.parse(params[:date])
          budgets = budgets.for_month(date)
        end

        render_success(budgets: budgets)
      end

      def show
        render_success(budget: @budget)
      end

      def create
        budget = Budget.create!(budget_params)
        render_success({ budget: budget }, :created)
      end

      def update
        @budget.update!(budget_params)
        render_success(budget: @budget)
      end

      def destroy
        @budget.destroy
        head :no_content
      end

      def progress
        progress_data = {
          budget: @budget,
          remaining: @budget.remaining,
          percentage_used: @budget.percentage_used,
          status: @budget.status,
          days_remaining: @budget.days_remaining,
          daily_budget: @budget.daily_budget
        }
        
        render_success(progress: progress_data)
      end

      private

      def set_budget
        @budget = Budget.find(params[:id])
      end

      def budget_params
        params.require(:budget).permit(
          :category_id,
          :budgeted,
          :spent,
          :start_date,
          :end_date
        )
      end
    end
  end
end
