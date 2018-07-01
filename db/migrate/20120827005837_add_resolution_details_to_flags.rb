class AddResolutionDetailsToFlags < ActiveRecord::Migration
  def change
    add_column :flags, :resolved_details, :string
  end
end
