class CreateKits < ActiveRecord::Migration
  def change
    create_table :kits do |t|
      t.string :name
      t.text :description
      t.integer :creator
      t.string :status
      t.integer :flow_order
      t.timestamps
    end
  end
end
