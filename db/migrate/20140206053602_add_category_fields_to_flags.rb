class AddCategoryFieldsToFlags < ActiveRecord::Migration[4.2]
  def change
    add_column :flags, :categoryId, :string
    add_column :flags, :categoryName, :string
  end
end
