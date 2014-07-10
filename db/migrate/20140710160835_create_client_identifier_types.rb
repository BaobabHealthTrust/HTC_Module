class CreateClientIdentifierTypes < ActiveRecord::Migration
  def change
    create_table :client_identifier_types do |t|

      t.timestamps
    end
  end
end
