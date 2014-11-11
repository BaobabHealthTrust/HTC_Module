class TestEncounter < ActiveRecord::Migration
  def change
    create_table :test_encounter do |t|
      t.string :test_encounter_type
      t.integer :creator
      t.datetime :encounter_datetime
      t.integer :location_id
      t.boolean :voided
      t.string :void_reason
      t.timestamps
    end
  end
end
