class CreatePhones < ActiveRecord::Migration[5.2]
  def change
    create_table :phones do |t|
      t.string :number
      t.boolean :mobile
      t.boolean :primary
      t.references :phonable, polymorphic: true

      t.timestamps
    end
  end
end
