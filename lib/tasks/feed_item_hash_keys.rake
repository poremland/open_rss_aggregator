namespace :feed_items do
	desc "Generates hash keys for feed items that don't have one"
	task :generate_hash_key => :environment do
		FeedItem.where('feed_items.key IS NULL').order('feed_id, id ASC').each do |item|
			item.key = item.generate_hash_key
			success = item.save
			puts "Generating key for feed: #{item.feed_id} item: #{item.id} link: #{item.link} key: #{item.key} success: #{success}"
		end
	end
end
