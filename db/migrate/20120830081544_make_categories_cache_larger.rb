class MakeCategoriesCacheLarger < ActiveRecord::Migration[4.2]
  def up
    change_column :categories_caches, :categories, :text, :limit => 16777215 
  end

  def down
  end
end
