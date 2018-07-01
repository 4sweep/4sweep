class AddCreatorIdToFlags < ActiveRecord::Migration
  def change
    add_column :flags, :creator_id, :string
  end
end
