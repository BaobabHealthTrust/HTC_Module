class CreateVillages < ActiveRecord::Migration
  def change
    create_table :villages do |t|

      t.timestamps
    end
  end
end
