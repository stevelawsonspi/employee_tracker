class CreateBusinessAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :business_addresses do |t|
      t.references :business, foreign_key: true
      t.string :unit
      t.string :street
      t.string :suburb
      t.string :state
      t.string :post_code

      t.timestamps
    end
  end
end
