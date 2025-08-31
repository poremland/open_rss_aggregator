class ChangeDatabaseCharset < ActiveRecord::Migration[6.1]
  def up
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      execute "ALTER DATABASE NetOremlandRSS_production CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;"
    end
  end

  def down
    if ActiveRecord::Base.connection.adapter_name == 'Mysql2'
      execute "ALTER DATABASE NetOremlandRSS_production CHARACTER SET = utf8 COLLATE = utf8_general_ci;"
    end
  end
end

