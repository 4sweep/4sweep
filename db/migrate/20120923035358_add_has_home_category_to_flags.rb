class AddHasHomeCategoryToFlags < ActiveRecord::Migration[4.2]
  def change
    add_column :flags, :primaryHasHome, :boolean
    add_column :flags, :secondaryHasHome, :boolean
  end
end
