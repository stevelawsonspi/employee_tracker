class UserBusinessesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_business, only: [:show, :edit, :update, :destroy]

  # GET /businesses
  # GET /businesses.json
  def index
    @businesses = current_user.businesses
  end

  # GET /businesses/1
  # GET /businesses/1.json
  def show
    @disable_fields = true
  end

  # GET /businesses/new
  def new
    @business = Business.new(user_id: current_user.id)
  end

  # GET /businesses/1/edit
  def edit
  end

  # POST /businesses
  # POST /businesses.json
  def create
    @business = Business.new(business_params)
    @business.user_id = current_user.id
    if @business.save
      redirect_to user_businesses_path, notice: "#{@business.name} was successfully created."
    else
      render :new
    end
  end

  # PATCH/PUT /businesses/1
  # PATCH/PUT /businesses/1.json
  def update
    if @business.update(business_params)
      redirect_to user_businesses_path, notice: "#{@business.name} was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /businesses/1
  # DELETE /businesses/1.json
  def destroy
    @business.destroy
    redirect_to user_businesses_url, notice: "#{@business.name} was successfully destroyed."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_business
      @business = Business.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def business_params
      params.require(:business).permit(:name, :abn)
    end
end
