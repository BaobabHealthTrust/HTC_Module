class TestObservation < ActiveRecord::Migration
  def change
    create_table :test_observation do |t|
      t.string :encounter_id
      t.integer :concept_id 
      t.integer :value_numeric
      t.string :value_text
      t.datetime :value_date
      t.datetime :obs_datetime
      t.integer :location_id
      t.boolean :voided
      t.string :void_reason
      t.timestamps
    end
  end
end
