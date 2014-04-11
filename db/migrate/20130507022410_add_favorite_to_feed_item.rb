class AddFavoriteToFeedItem < ActiveRecord::Migration
  def change
	add_column :feed_items, :favorite, :boolean, :default => 0
  end
end
