class CreateEmployeeAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :employee_addresses do |t|
      t.references :employee, foreign_key: true
      t.string :unit
      t.string :street
      t.string :suburb
      t.string :state
      t.string :post_code
      t.boolean :primary
      t.boolean :mailing_address

      t.timestamps
    end
  end
end
