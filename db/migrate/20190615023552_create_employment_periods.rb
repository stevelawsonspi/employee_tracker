class CreateEmploymentPeriods < ActiveRecord::Migration[5.2]
  def change
    create_table :employment_periods do |t|
      t.references :employee, foreign_key: true
      t.references :department, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.string :position
      t.string :salary

      t.timestamps
    end
  end
end
