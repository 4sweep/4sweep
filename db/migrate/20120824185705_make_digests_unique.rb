class MakeDigestsUnique < ActiveRecord::Migration[4.2]
  def up
    digests = CategoriesCache.all.map {|e| e.digest}.uniq
    digests.each do |d|
      earliest = CategoriesCache.find_all_by_digest(d).sort_by {|e| e.created_at}.first
      latest = CategoriesCache.find_all_by_digest(d).sort_by {|e| e.created_at}.last
      if earliest.last_verified == nil
        earliest.last_verified = latest.created_at
        earliest.save
      end
    end
    CategoriesCache.where('"last_verified" is null').each do |c|
      c.delete
    end
  end

  def down
  end
end
