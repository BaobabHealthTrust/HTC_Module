class CreateChildProtocols < ActiveRecord::Migration
  def change
    create_table :child_protocols do |t|

      t.timestamps
    end
  end
end
