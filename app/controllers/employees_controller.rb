class EmployeesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_employee, only: [:show, :edit, :update, :destroy, :use]

  def index
    table_page_size = 20
    if params[:search].present?
      @pagy, @employees = pagy(
        Deparment.order(:name)
          .where("LOWER(email) LIKE :search OR LOWER(name) LIKE :search OR LOWER(abn) LIKE :search", {search: "%#{params[:search].downcase}%"}),
        items: table_page_size
      )
    else
      @pagy, @departments = pagy(Department.order(:name), items: table_page_size)
    end
  end

  def show
    @disable_fields = true
  end

  def new
    @department = Department.new(business_id: current_business.id)
  end

  def edit
  end

  def create
    @department = Department.new(department_params)
    @department.business_id = current_business.id
    if @department.save
      redirect_to business_departments_path(current_business), notice: "#{@department.name} was successfully created."
    else
      render :new
    end
  end

  def update
    if @department.update(department_params)
      redirect_to business_departments_path(current_business), notice: "#{@department.name} was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @department.destroy
    redirect_to business_departments_path(current_business), notice: "#{@department.name} was successfully destroyed."
  end

  private

    def set_employee
      @department = Employee.find(params[:id])
    end

    def employee_params
      params.require(:employee).permit(:department_id, :first_name, :last_name)
    end
end
