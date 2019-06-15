class CreatePhoneNumbers < ActiveRecord::Migration[5.2]
  def change
    create_table :phone_numbers do |t|
      t.string :number
      t.boolean :mobile
      t.boolean :primary
      t.references :phone_numberable, polymorphic: true

      t.timestamps
    end
  end
end
