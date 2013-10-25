require "table_renamable/engine"

module TableRenamable

  extend ActiveSupport::Autoload

  autoload :ConnectionAdapters
  autoload :DeprecatedTable
  autoload :Model

end
