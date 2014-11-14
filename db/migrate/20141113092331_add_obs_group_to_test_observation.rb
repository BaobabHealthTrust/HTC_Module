class AddObsGroupToTestObservation < ActiveRecord::Migration
  def change
    add_column :test_observation, :obs_group_id, :double
  end
end
