class AddHasHomeCategoryToFlags < ActiveRecord::Migration
  def change
    add_column :flags, :primaryHasHome, :boolean
    add_column :flags, :secondaryHasHome, :boolean
  end
end
