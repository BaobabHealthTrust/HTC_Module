class CreateConceptAnswers < ActiveRecord::Migration
  def change
    create_table :concept_answers do |t|

      t.timestamps
    end
  end
end
