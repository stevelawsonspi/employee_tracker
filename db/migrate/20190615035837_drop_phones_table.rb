class DropPhonesTable < ActiveRecord::Migration[5.2]
  def up
    drop_table :phones
  end
end
