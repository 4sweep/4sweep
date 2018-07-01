class AddFlagsMulticolumnIndex < ActiveRecord::Migration
  def up
  	add_index :flags, [:user_id, :status, :created_at]
  end

  def down
  	remove_index :flags, [:user_id, :status, :created_at]
  end
end
