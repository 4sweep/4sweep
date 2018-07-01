class AddCacheToUser < ActiveRecord::Migration
  def change
    add_column :users, :user_cache, :text
    add_column :users, :cached_at, :timestamp
  end
end
