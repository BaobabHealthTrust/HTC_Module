class CreateConceptNameTags < ActiveRecord::Migration
  def change
    create_table :concept_name_tags do |t|

      t.timestamps
    end
  end
end
