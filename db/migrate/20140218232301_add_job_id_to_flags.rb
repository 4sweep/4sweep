class AddJobIdToFlags < ActiveRecord::Migration[4.2]
  def change
    add_column :flags, :job_id, :integer
  end
end
