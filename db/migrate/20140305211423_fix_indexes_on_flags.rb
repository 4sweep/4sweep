class FixIndexesOnFlags < ActiveRecord::Migration
  def up
    remove_index :flags, :user_id
    add_index :flags, [:user_id, :status, :venueId]
    add_index :flags, [:user_id, :status, :secondaryVenueId]
  end

  def down
    add_index :flags, :user_id
    remove_index :flags, [:user_id, :status, :venueId]
    remove_index :flags, [:user_id, :status, :secondaryVenueId]
  end
end
