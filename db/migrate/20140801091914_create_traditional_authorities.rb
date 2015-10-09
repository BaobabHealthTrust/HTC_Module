class CreateTraditionalAuthorities < ActiveRecord::Migration
  def change
    create_table :traditional_authorities do |t|

      t.timestamps
    end
  end
end
