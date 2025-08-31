class ChangeFeedItemsColumnsToConsistentlyUseUtf8Mb4 < ActiveRecord::Migration[6.1]
  def change
    charset = ActiveRecord::Base.connection.adapter_name == 'Mysql2' ? 'utf8mb4' : nil
    collation = ActiveRecord::Base.connection.adapter_name == 'Mysql2' ? 'utf8mb4_unicode_ci' : nil

    change_column :feed_items, :title, :string, limit: 255, charset: charset, collation: collation
    change_column :feed_items, :link, :string, limit: 255, charset: charset, collation: collation
    change_column :feed_items, :timestamp, :string, limit: 255, charset: charset, collation: collation
    change_column :feed_items, :key, :string, limit: 255, charset: charset, collation: collation
    change_column :feed_items, :media, :string, limit: 255, charset: charset, collation: collation
  end
end

