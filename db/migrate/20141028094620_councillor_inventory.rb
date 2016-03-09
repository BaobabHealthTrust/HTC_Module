class CouncillorInventory < ActiveRecord::Migration
  def change
    create_table :councillor_inventory do |t|
      t.string :lot_no
      t.integer :councillor_id
      t.integer :room_id
      t.string :value_text
      t.integer :value_numeric
      t.datetime :value_date
      t.datetime :encounter_date
      t.integer :inventory_type
      t.text :comments
      t.integer :location_id
      t.integer :creator
      t.boolean :voided
      t.string :void_reason
      t.timestamps
    end
  end
end
