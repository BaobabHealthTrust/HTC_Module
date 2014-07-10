class CreateClientIdentifiers < ActiveRecord::Migration
  def change
    create_table :client_identifiers do |t|

      t.timestamps
    end
  end
end
