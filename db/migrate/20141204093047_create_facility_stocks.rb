class CreateFacilityStocks < ActiveRecord::Migration
  def change
    create_table :facility_stocks do |t|

      t.timestamps
    end
  end
end
