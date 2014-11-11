class TestEncounterType < ActiveRecord::Migration
  def change
    create_table :test_encounter_type do |t|
      t.string :name
      t.string :description
      t.integer :creator
      t.string :status
      t.timestamps
    end
  end
end
