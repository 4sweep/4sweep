class AddIndexOnCreatorId < ActiveRecord::Migration
  def change
    add_index :flags, [:user_id, :status, :creatorId, :type]

    remove_index :flags, [:user_id, :status, :venueId]
    remove_index :flags, [:user_id, :status, :secondaryVenueId]

    add_index :flags, [:user_id, :status, :venueId, :type]
    add_index :flags, [:user_id, :status, :secondaryVenueId, :type]
  end
end
