class RenameCreatorId < ActiveRecord::Migration
  def change
    rename_column :flags, :creator_id, :creatorId
  end
end
