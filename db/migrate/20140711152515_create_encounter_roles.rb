class CreateEncounterRoles < ActiveRecord::Migration
  def change
    create_table :encounter_roles do |t|

      t.timestamps
    end
  end
end
