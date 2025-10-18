module Api
  module V1
    class BudgetsController < BaseController
      before_action :set_budget, only: [:show, :update, :destroy, :progress]

      def index
        budgets = Budget.includes(:budget_categories).all
        budgets = budgets.active if params[:active].present?
        
        if params[:date]
          date = Date.parse(params[:date])
          budgets = budgets.for_month(date)
        end

        serialized_budgets = budgets.map { |budget| BudgetSerializer.new(budget).as_json }
        render_success(budgets: serialized_budgets)
      end

      def show
        serialized_budget = BudgetSerializer.new(@budget).as_json
        render_success(budget: serialized_budget)
      end

      def create
        budget = current_user.budgets.create!(budget_params)
        serialized_budget = BudgetSerializer.new(budget).as_json
        render_success({ budget: serialized_budget }, :created)
      end

      def update
        @budget.update!(budget_params)
        serialized_budget = BudgetSerializer.new(@budget).as_json
        render_success(budget: serialized_budget)
      end

      def destroy
        @budget.destroy
        head :no_content
      end

      def progress
        progress_data = {
          budget: @budget,
          total_budgeted: @budget.total_budgeted,
          spent: @budget.spent,
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
          :name,
          :start_date,
          :end_date,
          :currency,
          budget_categories_attributes: [:category_id, :budgeted_spend]
        )
      end
    end
  end
end
