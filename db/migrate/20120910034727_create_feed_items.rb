class CreateFeedItems < ActiveRecord::Migration
	def change
		create_table :feed_items do |t|
			t.integer :feed_id
			t.string :title, :options => 'CHARSET=utf8'
			t.string :link
			t.string :description
			t.boolean :display, :default => 1
			t.string :timestamp
			t.timestamps
		end
	end
end
