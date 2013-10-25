module TableRenamable
  class Engine < ::Rails::Engine
    isolate_namespace TableRenamable

    config.after_initialize do
      # set up our reload behavior for when table names change for MySQL
      if defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
        ActiveRecord::ConnectionAdapters::Mysql2Adapter.send(
          :include,
          TableRenamable::ConnectionAdapters::Mysql2Adapter
        )
      # same thing for SQLite
      elsif defined?(ActiveRecord::ConnectionAdapters::SQLite3Adapter)
        ActiveRecord::ConnectionAdapters::SQLite3Adapter.send(
          :include,
          TableRenamable::ConnectionAdapters::SQLite3Adapter
        )
      end
    end

  end
end
