class AddResolutionDetailsToFlags < ActiveRecord::Migration[4.2]
  def change
    add_column :flags, :resolved_details, :string
  end
end
