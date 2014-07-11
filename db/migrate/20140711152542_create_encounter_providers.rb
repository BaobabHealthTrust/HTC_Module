class CreateEncounterProviders < ActiveRecord::Migration
  def change
    create_table :encounter_providers do |t|

      t.timestamps
    end
  end
end
