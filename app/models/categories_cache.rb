class CategoriesCache < ActiveRecord::Base
  attr_accessible :categories

  MAX_AGE = 1.hour

  def self.latest
    cat = first(:order => "created_at desc")
    cat ||= fetch
    if (cat.last_verified == nil) or (Time.now - cat.last_verified > MAX_AGE) and (Delayed::Job.where('queue = ?', 'category_refresh').count == 0)
      delay(:queue => "category_refresh", :priority => 10).fetch
    end
    cat
  end

  def self.fetch
    foursquare_userless = Foursquare2::Client.new(:client_id => Settings.app_id, :client_secret => Settings.app_secret, :api_version => "20140218")
    c = foursquare_userless.venue_categories.to_json
    latest = first(:order => "created_at desc")
    test = new(:categories => c)
    if latest && test.digest == latest.digest
      latest.last_verified = Time.now
      latest.save
      return latest
    else
      test.last_verified = Time.now
      test.save
      return test
    end

  end

  def aslist
    c = JSON.parse(categories)
    list_helper(c, "")
  end

  def categories= (value)
    write_attribute(:categories, value)
    write_attribute(:digest, set_digest)
  end

  def set_digest 
    # Digest should incorporate other information, like icons
    digest = Digest::SHA1.hexdigest(aslist.join("\n"))
  end

  private
  def list_helper(categories, prefix)
    result = []
    # sort categories by name
    categories.each do |c|
      result << prefix + c['name']
      if c['categories']
        list_helper(c['categories'], prefix + c['name'] + " > ").each do |sub|
          result << sub
        end
      end
      # c['categories'].each do |sub|
        # result << list_helper(sub, prefix + c['name'] + " > ")
      # end
    end
    result
  end
end
