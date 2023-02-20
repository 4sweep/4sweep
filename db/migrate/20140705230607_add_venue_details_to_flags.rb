class AddVenueDetailsToFlags < ActiveRecord::Migration[4.2]
  def change
    add_column :flags, :venues_details, :text
  end
end
