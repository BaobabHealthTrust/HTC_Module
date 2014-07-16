class CreateConceptNameTagMaps < ActiveRecord::Migration
  def change
    create_table :concept_name_tag_maps do |t|

      t.timestamps
    end
  end
end
