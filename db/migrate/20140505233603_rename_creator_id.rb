class RenameCreatorId < ActiveRecord::Migration[4.2]
  def change
    rename_column :flags, :creator_id, :creatorId
  end
end
