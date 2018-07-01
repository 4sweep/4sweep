class AddJobIdToFlags < ActiveRecord::Migration
  def change
    add_column :flags, :job_id, :integer
  end
end
