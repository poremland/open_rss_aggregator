class ChangeDescriptionToLongtext < ActiveRecord::Migration[6.1]
  def change
    charset = ActiveRecord::Base.connection.adapter_name == 'Mysql2' ? 'utf8mb4' : nil
    collation = ActiveRecord::Base.connection.adapter_name == 'Mysql2' ? 'utf8mb4_unicode_ci' : nil

    change_column :feed_items, :description, :longtext, charset: charset, collation: collation
  end
end
