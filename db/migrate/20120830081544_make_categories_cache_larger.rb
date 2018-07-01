class MakeCategoriesCacheLarger < ActiveRecord::Migration
  def up
    change_column :categories_caches, :categories, :text, :limit => 16777215 
  end

  def down
  end
end
