require 'open-uri'

def cat_icon_urls
  client = Foursquare2::Client.new(:client_id => Settings.app_id, :client_secret => Settings.app_secret, :api_version => '20121015')
  all_cats = client.venue_categories

  urls = sub_prefixes(all_cats)
  urls << "https://ss3.4sqi.net/img/categories_v2/none_"
  urls.uniq
end

def sub_prefixes(cats)
  urls = []
  cats.each do |cat|
    urls << cat.icon.prefix
    if cat.categories
      urls += sub_prefixes(cat.categories)
    end
  end
  urls
end

task :upload_cat_icons => :environment do
  urls = cat_icon_urls

  s3 = AWS::S3.new(
    :access_key_id     => Settings.aws_key,
    :secret_access_key => Settings.aws_secret
  )

  urls.each do |url|
    puts "Attempting: #{url}"
    begin
      blob = open(url + "32.png").read
    rescue OpenURI::HTTPError => e
      puts "HTTP Error fetching #{url}: #{e.message}"
      next
    end
    icon = Magick::Image.from_blob(blob).first

    background_gray = Magick::Image.new(icon.columns, icon.rows) { self.background_color='#cccccc'}
    background_orange = Magick::Image.new(icon.columns, icon.rows) { self.background_color='#FFAF7A'}
    background_green = Magick::Image.new(icon.columns, icon.rows) { self.background_color='#b7cda9'}
    background_faded = Magick::Image.new(icon.columns, icon.rows) { self.background_color='#eeeeee'}

    filename = url.gsub("https://ss1.4sqi.net/img/categories_v2/", "")
    bordered =  background_gray.composite(icon, 0, 0, Magick::AtopCompositeOp).border(2,2,'#888888')
    orange = background_orange.composite(icon, 0, 0, Magick::AtopCompositeOp).border(2,2, "#888888")
    green = background_green.composite(icon, 0, 0, Magick::AtopCompositeOp).border(2,2, "#888888")
    faded = background_faded.composite(icon, 0, 0, Magick::AtopCompositeOp).border(2,2, "#aaaaaa")

    files = {
      :bordered => bordered,
      :green => green,
      :orange => orange,
      :faded => faded
    }

    files.each_pair do |name, image|
      destination = filename + "32_#{name.to_s}.png"

      obj = s3.buckets[Settings.s3_bucket].objects[destination]
      obj.write(image.to_blob {self.format = 'png'}, :mime_type => "image/png")
      # s3.store(
      #   destination,
      #   image.to_blob {self.format = 'png'},
      #   Settings.s3_bucket,
      #   :mime_type => "image/png"
      # )
      puts "Put #{destination}"
    end
  end
end
