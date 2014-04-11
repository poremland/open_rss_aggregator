class AddFeedItemIndexes < ActiveRecord::Migration
  def up
	add_index :feed_items, :feed_id
	add_index :feed_items, :display
  end

  def down
	remove_index :feed_items, :feed_id
	remove_index :feed_items, :display
  end
end
