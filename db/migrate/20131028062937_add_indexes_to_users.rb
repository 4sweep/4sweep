class AddIndexesToUsers < ActiveRecord::Migration
  def change
  	add_index :users, :token
  	add_index :users, :uid
  end
end
