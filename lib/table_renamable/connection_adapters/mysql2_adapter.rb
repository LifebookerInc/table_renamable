module TableRenamable
  module ConnectionAdapters
    module Mysql2Adapter

      def self.included(klass)
        klass.send(:include, InstanceMethods)
        klass.alias_method_chain(:execute, :table_renamable)
      end


      module InstanceMethods
        #
        # Override execute to reload database info
        # @param  *args [Array<Mixed>] Just here so we can call super
        #
        # @return [type] [description]
        def execute_with_table_renamable(sql, name = nil)
          # set up tries so we don't keep retrying
          tries = 0
          begin
            tries += 1
            # call the actual execut behavior
            self.execute_without_table_renamable(sql, name)
          rescue ActiveRecord::StatementInvalid => e
            # only try once
            raise e if tries > 1
            # re-raise if it's not an error we care about
            raise e unless e.message =~ /Table.*doesn't exist/
            # otherwise we reload and retry
            TableRenamable::Model.reload_tables
            sql = TableRenamable::Model.process_sql(sql)
            retry
          end
        end
      end

    end
  end
end