class AddFavoriteToFeedItem < ActiveRecord::Migration[6.1]
  def change
	add_column :feed_items, :favorite, :boolean, :default => 0
  end
end
