class AddCategoryToFeeds < ActiveRecord::Migration[8.1]
  def change
    add_column :feeds, :category, :string
  end
end
