class AddCacheToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :user_cache, :text
    add_column :users, :cached_at, :timestamp
  end
end
