class CreateCounselingQuestions < ActiveRecord::Migration
  def change
    create_table :counseling_questions do |t|

      t.timestamps
    end
  end
end
