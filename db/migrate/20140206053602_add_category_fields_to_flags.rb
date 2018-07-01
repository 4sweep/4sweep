class AddCategoryFieldsToFlags < ActiveRecord::Migration
  def change
    add_column :flags, :categoryId, :string
    add_column :flags, :categoryName, :string
  end
end
