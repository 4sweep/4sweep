class AddIndexToCategoryCaches < ActiveRecord::Migration
  def change
    add_index :categories_caches, :created_at
  end
end
