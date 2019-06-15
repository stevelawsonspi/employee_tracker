class CreateEmails < ActiveRecord::Migration[5.2]
  def change
    create_table :emails do |t|
      t.string :email
      t.boolean :primary
      t.references :emailable, polymorphic: true

      t.timestamps
    end
  end
end
