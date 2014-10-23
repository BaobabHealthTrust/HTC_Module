class CreateInventoryTypes < ActiveRecord::Migration
  def change
    create_table :inventory_type do |t|
      t.string :name
      t.text :description
      t.integer :creator
      t.timestamps
    end
  end
end
