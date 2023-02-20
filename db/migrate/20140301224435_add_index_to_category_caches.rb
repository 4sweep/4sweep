class AddIndexToCategoryCaches < ActiveRecord::Migration[4.2]
  def change
    add_index :categories_caches, :created_at
  end
end
