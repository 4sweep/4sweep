class AddHashAndVerifiedDateToCategoriesCache < ActiveRecord::Migration[4.2]
  def change
    add_column :categories_caches, :last_verified, :timestamp
    add_column :categories_caches, :digest, :string

    CategoriesCache.all.each do |c|
      c.digest = Digest::SHA1.hexdigest(c.aslist.join("\n"))
      c.save
    end
  end
end
