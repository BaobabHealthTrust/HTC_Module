class AddValueGroupToTestObservation < ActiveRecord::Migration
  def change
    add_column :test_observation, :value_group_id, :double
  end
end
