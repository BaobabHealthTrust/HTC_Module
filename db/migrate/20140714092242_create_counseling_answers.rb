class CreateCounselingAnswers < ActiveRecord::Migration
  def change
    create_table :counseling_answers do |t|

      t.timestamps
    end
  end
end
