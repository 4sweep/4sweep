class AddCreatorIdToFlags < ActiveRecord::Migration[4.2]
  def change
    add_column :flags, :creator_id, :string
  end
end
