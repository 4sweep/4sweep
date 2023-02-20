class AddPhotoFieldsToFlags < ActiveRecord::Migration[4.2]
  def change
    add_column :flags, :creatorName, :string
    rename_column :flags, :categoryId, :itemId
    rename_column :flags, :categoryName, :itemName
  end
end
