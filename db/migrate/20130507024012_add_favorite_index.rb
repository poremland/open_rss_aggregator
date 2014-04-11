class AddFavoriteIndex < ActiveRecord::Migration
  def up
	add_index :feed_items, [:feed_id, :favorite]
  end

  def down
	remove_index :feed_items, [:feed_id, :favorite]
  end
end
