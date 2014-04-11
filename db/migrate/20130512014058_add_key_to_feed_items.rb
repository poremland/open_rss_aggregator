class AddKeyToFeedItems < ActiveRecord::Migration
  def change
	add_column :feed_items, :key, :string
	add_index :feed_items, [:feed_id, :key]
  end
end
