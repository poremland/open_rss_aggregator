class Feed < ActiveRecord::Base
	has_many :feed_items, :inverse_of => :feed, :foreign_key => :feed_id, :conditions => { 'display' => true }, :order => 'id ASC', :dependent => :destroy

	def update_feed_items
		begin
			rss = Feedzirra::Feed.fetch_and_parse(self.uri)
		rescue => e
			puts "Error updating feed items for feed: #{self.uri}. #{e.message}"
			return
		end

		if(rss.nil? || rss == 0)
			puts "Error updating feed items for feed: #{self.uri}. Unable to fetch and parse #{self.uri}"
			return
		end

		domain = get_domain(rss)

		rss.entries.each do |item|
			date = get_date(item)
			hash_key = get_hash_key(item, date)
			count = FeedItem.count(:id, :conditions => { "key" => hash_key, "feed_id" => self.id })
			next unless count == 0

			self.feed_items << create_feed_item(item, get_link(item), domain, hash_key, date)
		end
	end

	def create_feed_item(item, link, domain, hash_key, date)
		description = get_description(item, domain)
    title = get_title(item, description, hash_key)
		fi = FeedItem.new
		fi.title = title
		fi.link = link
		fi.description = description
		fi.timestamp = date
		fi.key = hash_key
		fi.save
		fi
	end

  def get_title(item, description, key)
    title = item.title.sanitize unless item.title.nil?
    title = "#{description[0,47]}..." if title.nil? && !description.nil?
    title = "No Title: #{key}" if title.nil?
		CGI.unescapeHTML(title)
  end

	def get_link(item)
		item.url =~ /^http/ ? item.url : item.entry_id
	end

	def get_hash_key(item, date)
		opts = {
			:title => item.title || "",
			:link => get_link(item),
			:timestamp => date
		}
		FeedItem.hash_key_from_opts opts
	end

	def get_description(item, domain)
		# make sure all img urls are absolute
		description = item.content.nil? ? item.summary.nil? ? "Visit Site to view this post" : item.summary.sanitize : item.content.sanitize
		description = CGI.unescapeHTML(description)
		description = strip_scripts(description)
		description = fully_qualify_src_attribute_urls(description, domain)
	end

	def get_domain(rss)
		# get the domain to prepend to image urls that don't have one
		domain = rss.feed_url =~ /^http/ ? rss.feed_url : rss.url
	end

	def fully_qualify_src_attribute_urls(description, domain)
		description.gsub(/src=\"[^\"]*\"/) do |match|
			replacement = ""
			path = match[5, match.length - 6]

			if path && path[0,4] == "http"
				replacement = match
			elsif path && path[0,1] == "/"
				replacement = "src=\"#{domain}#{path}\""
			else
				replacement = "src=\"#{domain}/#{path}\""
			end
			replacement
		end
	end

	def strip_scripts(text)
		text.gsub(/<script[^>]*>[^<]*<\/script>/i, "");
	end

	def get_date(item)
		item.published || ""
	end
end
