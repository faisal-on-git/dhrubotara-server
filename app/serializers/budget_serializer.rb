class BudgetSerializer
  def initialize(budget)
    @budget = budget
  end

  def as_json
    {
      id: @budget.id,
      user_id: @budget.user_id,
      name: @budget.name,
      start_date: @budget.start_date,
      end_date: @budget.end_date,
      currency: @budget.currency,
      budget_categories: @budget.budget_categories.map do |bc|
        {
          id: bc.id,
          budget_id: bc.budget_id,
          category_id: bc.category_id,
          budgeted_spend: bc.budgeted_spend.to_f,
          created_at: bc.created_at,
          updated_at: bc.updated_at
        }
      end,
      created_at: @budget.created_at,
      updated_at: @budget.updated_at
    }
  end
end

