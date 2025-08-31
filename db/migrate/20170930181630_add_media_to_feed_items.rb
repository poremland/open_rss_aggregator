class AddMediaToFeedItems < ActiveRecord::Migration[6.1]
  def change
	add_column :feed_items, :media, :string
  end
end
