class AddMultiColumnFeedItemIndexes < ActiveRecord::Migration[6.1]
  def up
	add_index :feed_items, [:feed_id, :display]
  end

  def down
	remove_index :feed_items, [:feed_id, :display]
  end
end
