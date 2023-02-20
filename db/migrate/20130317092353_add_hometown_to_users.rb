class AddHometownToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :hometown, :string
  end
end
