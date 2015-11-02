class CreateInventory < ActiveRecord::Migration
  def change
    create_table :inventory do |t|
      t.string :lot_no
      t.integer :kit_type
      t.integer :inventory_type
      t.string :value_text
      t.integer :value_numeric
      t.datetime :value_date
      t.datetime :date_of_expiry
      t.datetime :encounter_date
      t.text :comments
      t.integer :location_id
      t.integer :creator
      t.boolean :voided
      t.string :void_reason
      t.timestamps
    end
  end
end
