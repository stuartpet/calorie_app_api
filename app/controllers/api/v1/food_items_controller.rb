module Api
  module V1
    class FoodItemsController < ApplicationController
      before_action :authenticate_user!, except: [:index, :show]

      def index
        if params[:name].present?
          item = FoodItem.find_by('LOWER(name) = ?', params[:name].downcase)
          if item
            render json: FoodItemSerializer.new(item).as_json
          else
            render json: {
              error: "No match for '#{params[:name]}'",
              suggestion: "Would you like to add this as a new food item?"
            }, status: :not_found
          end
        elsif params[:query].present?
          matches = FoodItem.where('LOWER(name) LIKE ?', "%#{params[:query].downcase}%")
          render json: ActiveModelSerializers::SerializableResource.new(matches, each_serializer: FoodItemSerializer)
        else
          render json: ActiveModelSerializers::SerializableResource.new(FoodItem.all, each_serializer: FoodItemSerializer)
        end
      end

      def show
        item = FoodItem.find_by(id: params[:id])
        if item
          render json: FoodItemSerializer.new(item).as_json
        else
          render json: { error: 'Food item not found' }, status: :not_found
        end
      end

      # EXISTING action: Create a meal based on a known FoodItem
      def create
        item = FoodItem.find_by(id: params[:food_item_id])
        unless item
          return render json: { error: "Food item not found" }, status: :not_found
        end

        meal = @current_user.meals.create!(
          food_item: item,
          name: item.name,
          calories: item.calories,
          protein: item.protein,
          carbs: item.carbs,
          fat: item.fat,
          sugar: item.sugar,
          salt: item.salt
        )

        render json: meal, status: :created
      end

      # NEW: Create a custom fallback FoodItem with uploaded image
      def create_custom
        food_item = FoodItem.new(food_item_params)
        food_item.user_generated = true

        if food_item.save
          if params[:image].present?
            io = StringIO.new(Base64.decode64(params[:image]))
            filename = "#{food_item.id}/#{food_item.name.parameterize}.jpg"
            SupabaseUploader.upload(io, filename)
          end

          render json: FoodItemSerializer.new(food_item).as_json, status: :created
        else
          render json: { errors: food_item.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        item = FoodItem.find(params[:id])
        if item.update(food_item_params)
          render json: FoodItemSerializer.new(item).as_json
        else
          render json: { error: item.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # Barcode lookup with OpenFoodFacts fallback
      def barcode_lookup
        if params[:barcode].blank?
          return render json: { error: 'Barcode is required' }, status: :bad_request
        end

        item = FoodItem.find_by(barcode: params[:barcode])
        return render json: FoodItemSerializer.new(item).as_json if item

        fallback_item = OpenFoodFactsService.find_by_barcode(params[:barcode])
        if fallback_item
          render json: FoodItemSerializer.new(fallback_item).as_json, status: :created
        else
          render json: { error: "No match found in OpenFoodFacts for barcode '#{params[:barcode]}'" }, status: :not_found
        end
      end

      private

      def food_item_params
        params.require(:food_item).permit(:name, :description, :calories, :protein, :carbs, :fat, :sugar, :salt, :source, :barcode)
      end
    end
  end
end
