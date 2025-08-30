module Api
  module V1
    class DashboardController < BaseController
      def summary
        start_month = Date.current.beginning_of_month
        end_month   = Date.current.end_of_month

        summary_data = {
          net_worth: calculate_net_worth,
          month_to_date: {
            income: Transaction.income.for_period(start_month, end_month).sum(:amount),
            expenses: Transaction.expense.for_period(start_month, end_month).sum(:amount)
          },
          accounts: {
            assets: Account.assets.sum(:balance),
            liabilities: Account.liabilities.sum(:balance)
          },
          budgets: {
            total_budgeted: Budget.active.sum(:budgeted),
            total_spent: Budget.active.sum(:spent)
          }
        }

        render_success(summary: summary_data)
      end

      def net_worth
        data = {
          total: calculate_net_worth,
          breakdown: {
            assets: Account.assets.map { |a| { name: a.name, amount: a.balance } },
            liabilities: Account.liabilities.map { |a| { name: a.name, amount: a.balance } }
          }
        }

        render_success(net_worth: data)
      end

      def cash_flow
        start_param = params[:start_date]
        end_param   = params[:end_date]

        start_date = start_param ? Date.parse(start_param.to_s) : Date.current.beginning_of_month
        end_date   = end_param   ? Date.parse(end_param.to_s)   : Date.current.end_of_month

        data = {
          period: {
            start_date: start_date,
            end_date: end_date
          },
          income: Transaction.income
                           .for_period(start_date, end_date)
                           .left_joins(:category)
                           .group("COALESCE(categories.name, 'Uncategorized')")
                           .sum(:amount),
          expenses: Transaction.expense
                               .for_period(start_date, end_date)
                               .left_joins(:category)
                               .group("COALESCE(categories.name, 'Uncategorized')")
                               .sum(:amount),
          net: Transaction.income.for_period(start_date, end_date).sum(:amount) -
               Transaction.expense.for_period(start_date, end_date).sum(:amount)
        }

        render_success(cash_flow: data)
      end

      def budget_status
        active_budgets = Budget.active

        status_data = {
          total_budgets: active_budgets.count,
          total_budgeted: active_budgets.sum(:budgeted),
          total_spent: active_budgets.sum(:spent),
          budgets: active_budgets.map { |budget|
            {
              category: budget.category,
              budgeted: budget.budgeted,
              spent: budget.spent,
              remaining: budget.remaining,
              percentage_used: budget.percentage_used,
              status: budget.status
            }
          }
        }

        render_success(budget_status: status_data)
      end

      private

      def calculate_net_worth
        Account.all.sum(&:net_worth_impact)
      end
    end
  end
end 