class CreateCategoriesCaches < ActiveRecord::Migration[4.2]
  def change
    create_table :categories_caches do |t|
      t.text :categories

      t.timestamps
    end
  end
end
