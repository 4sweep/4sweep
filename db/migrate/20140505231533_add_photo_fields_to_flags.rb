class AddPhotoFieldsToFlags < ActiveRecord::Migration
  def change
    add_column :flags, :creatorName, :string
    rename_column :flags, :categoryId, :itemId
    rename_column :flags, :categoryName, :itemName
  end
end
