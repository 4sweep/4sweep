class AddVenueDetailsToFlags < ActiveRecord::Migration
  def change
    add_column :flags, :venues_details, :text
  end
end
