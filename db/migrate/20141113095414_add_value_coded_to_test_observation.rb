class AddValueCodedToTestObservation < ActiveRecord::Migration
  def change
    add_column :test_observation, :value_coded, :double
  end
end
