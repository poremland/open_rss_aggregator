class FeedItem < ApplicationRecord
	belongs_to :feed, :inverse_of => :feed_items, :foreign_key => :feed_id
	validates_presence_of :feed

	def generate_hash_key
		return @hash_key unless @hash_key.nil?
		opts = {
			:title => self.title,
			:link => self.link,
			:timestamp => self.timestamp
		}
		@hash_key = FeedItem.hash_key_from_opts opts
	end

	def self.hash_key_from_opts opts
		link = opts[:link]
		link = URI.encode_www_form_component(link) unless link.nil?
		domain = link
		domain = URI.parse(link) unless domain.nil?
		domain = domain.host.downcase unless domain.nil? || domain.host.nil?
		title = opts[:title]
		title = opts[:title].gsub(/[^0-9A-Za-z]/,'') unless title.nil?
		timestamp = opts[:timestamp]
		timestamp = Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ") if timestamp.nil?
		Digest::SHA1.hexdigest "#{domain}_#{title}_#{timestamp}"
	end
end

