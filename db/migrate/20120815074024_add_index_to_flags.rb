class AddIndexToFlags < ActiveRecord::Migration[4.2]
  def change
    add_index :flags, :venueId
  end
end
