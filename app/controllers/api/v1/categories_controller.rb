module Api
  module V1
    class CategoriesController < BaseController
      before_action :set_category, only: [:show, :update, :destroy]

      def index
        categories = current_user ? current_user.categories : Category.all
        render_success(categories: categories)
      end

      def show
        render_success(category: @category)
      end

      def create
        unless current_user
          return render json: { error: "Unauthorized" }, status: :unauthorized
        end

        category = current_user.categories.create!(category_params)
        render_success({ category: category }, :created)
      end

      def update
        @category.update!(category_params)
        render_success(category: @category)
      end

      def destroy
        @category.destroy
        head :no_content
      end

      private

      def set_category
        @category = current_user.categories.find(params[:id])
      end

      def category_params
        params.require(:category).permit(:name, :parent_id)
      end
    end
  end
end
