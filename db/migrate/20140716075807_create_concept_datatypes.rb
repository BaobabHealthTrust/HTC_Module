class CreateConceptDatatypes < ActiveRecord::Migration
  def change
    create_table :concept_datatypes do |t|

      t.timestamps
    end
  end
end
