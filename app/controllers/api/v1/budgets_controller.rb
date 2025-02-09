module Api
  module V1
    class BudgetsController < ApplicationController
      before_action :set_budget, only: [:show, :update, :destroy]

      def index
        @budgets = Budget.all
        render json: @budgets.map { |budget|
          budget.as_json.merge(
            remaining: budget.remaining,
            percentage_used: budget.percentage_used
          )
        }
      end

      def show
        render json: @budget.as_json.merge(
          remaining: @budget.remaining,
          percentage_used: @budget.percentage_used
        )
      end

      def create
        @budget = Budget.new(budget_params)

        if @budget.save
          render json: @budget, status: :created
        else
          render json: @budget.errors, status: :unprocessable_entity
        end
      end

      def update
        if @budget.update(budget_params)
          render json: @budget
        else
          render json: @budget.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @budget.destroy
        head :no_content
      end

      private

      def set_budget
        @budget = Budget.find(params[:id])
      end

      def budget_params
        params.require(:budget).permit(:category, :budgeted, :spent)
      end
    end
  end
end
