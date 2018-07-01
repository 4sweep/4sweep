class MakeUserCacheLarger < ActiveRecord::Migration
  def up
    change_column :users, :user_cache, :text, :limit => 16777215 
  end

  def down
  end
end
