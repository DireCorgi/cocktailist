module Api
  class CocktailsController < ApplicationController
    def index
      @cocktails = Cocktail.all.includes(:bar)
      render :index
    end

    def show
      @cocktail = current_cocktail
      render :show
    end

    def create
      clean_params = cocktail_params
      clean_params[:ingredients] = clean_params[:ingredients].downcase
      clean_params[:liquor] = clean_params[:liquor].downcase
      bar = Bar.find_by(name: clean_params[:bar_name])
      if bar.nil?
        Bar.create(name: clean_params[:bar_name], address: clean_params[:bar_address])
      end
      clean_params[:bar_id] = Bar.find_by(name: clean_params[:bar_name]).id
      clean_params.delete(:bar_name)
      clean_params.delete(:bar_address)
      @cocktail = Cocktail.new(clean_params)
      if @cocktail.save
        Feed.create(user_id: current_user.id, cocktail_id: @cocktail.id, activity: "added", data: @cocktail.ingredients+"; "+@cocktail.bar.name)
        render json: @cocktail
      else
        render json: @cocktail.errors.full_messages, status: :unprocessable_entity
      end
    end

    def edit
      @cocktail = current_cocktail
      if @cocktail.update(cocktail_params)
        render json: @cocktail
      else
        render json: @cocktail.errors.full_messages, status: :unprocessable_entity
      end
    end

    def destroy
      @cocktail = current_cocktail
      @cocktail.try(:destroy)
      render json: {}
    end

    private
    def current_cocktail
      Cocktail.includes(:bar).find(params[:id])
    end

    def cocktail_params
      params.require(:cocktail).permit(:name, :liquor, :ingredients, :bar_name, :bar_address)
    end
  end
end
