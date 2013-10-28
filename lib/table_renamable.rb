require "table_renamable/connection_adapters"
require "table_renamable/deprecated_table"
require "table_renamable/model"

module TableRenamable

end

# hook to set up rails
# set up our reload behavior for when table names change for MySQL
if defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
  ActiveRecord::ConnectionAdapters::Mysql2Adapter.send(
    :include,
    TableRenamable::ConnectionAdapters::Mysql2Adapter
  )
else
  raise 'TableRenamable requires Mysql2'
end


