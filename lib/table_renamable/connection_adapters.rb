module TableRenamable
  module ConnectionAdapters

    extend ActiveSupport::Autoload

    autoload :Mysql2Adapter
    autoload(
      :SQLite3Adapter,
      'table_renamable/connection_adapters/sqlite3_adapter'
    )

  end
end