class RemoveSalaryFromEmployeePeriod < ActiveRecord::Migration[5.2]
  def change
    remove_column :employment_periods, :salary, :string
    add_column    :employment_periods, :salary, :integer
  end
end
