class CreateConceptNumerics < ActiveRecord::Migration
  def change
    create_table :concept_numerics do |t|

      t.timestamps
    end
  end
end
