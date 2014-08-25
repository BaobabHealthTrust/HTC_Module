class AddFieldnameToCounselingQuestion < ActiveRecord::Migration
  def change
    add_column :counseling_question, :position, :decimal
  end
end
