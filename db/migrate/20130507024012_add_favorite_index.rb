class AddFavoriteIndex < ActiveRecord::Migration[6.1]
  def up
	add_index :feed_items, [:feed_id, :favorite]
  end

  def down
	remove_index :feed_items, [:feed_id, :favorite]
  end
end
