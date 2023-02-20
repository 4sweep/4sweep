class CreateUsers < ActiveRecord::Migration[4.2]
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
