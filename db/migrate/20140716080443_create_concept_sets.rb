class CreateConceptSets < ActiveRecord::Migration
  def change
    create_table :concept_sets do |t|

      t.timestamps
    end
  end
end
