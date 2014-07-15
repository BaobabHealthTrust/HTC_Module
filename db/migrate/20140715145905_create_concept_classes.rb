class CreateConceptClasses < ActiveRecord::Migration
  def change
    create_table :concept_classes do |t|

      t.timestamps
    end
  end
end
