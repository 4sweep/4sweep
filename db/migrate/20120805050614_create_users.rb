class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :level
      t.string :token
      t.boolean :enabled

      t.timestamps
    end
  end
end
