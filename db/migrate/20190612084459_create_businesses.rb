class CreateBusinesses < ActiveRecord::Migration[5.2]
  def change
    create_table :businesses do |t|
      t.references :user, foreign_key: true
      t.string :name
      t.string :abn

      t.timestamps
    end
  end
end
