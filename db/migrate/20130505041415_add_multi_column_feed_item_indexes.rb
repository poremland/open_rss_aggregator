class AddMultiColumnFeedItemIndexes < ActiveRecord::Migration
  def up
	add_index :feed_items, [:feed_id, :display]
  end

  def down
	remove_index :feed_items, [:feed_id, :display]
  end
end
