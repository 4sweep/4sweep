class ClearUserCaches < ActiveRecord::Migration[4.2]
  def up
    ActiveRecord::Base.connection.execute("update users set user_cache = null, cached_at = null")
  end

  def down

  end
end
