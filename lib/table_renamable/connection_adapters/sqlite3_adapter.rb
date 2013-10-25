module TableRenamable
  module ConnectionAdapters
    module SQLite3Adapter

      extend ActiveSupport::Concern

      # when we are included we add our behavior
      self.included do |klass|
        klass.alias_method_chain(:exec_query, :table_renamable)
        klass.alias_method_chain(:execute, :table_renamable)
        klass.alias_method_chain(:table_structure, :table_renamable)
      end

      def exec_query_with_table_renamable(*args, &block)
        self.with_retry do
          self.exec_query_without_table_renamable(*args, &block)
        end
      end

      #
      # Override execute to reload database info
      # @param  *args [Array<Mixed>] Just here so we can call super
      #
      # @return [type] [description]
      def execute_with_table_renamable(*args, &block)
        self.with_retry do
          self.execute_without_table_renamable(*args, &block)
        end
      end

      def table_structure_with_table_renamable(table_name)
        self.with_retry do
          # get the correct table name to check - otherwise this will fail
          # on retry
          current_table_name = TableRenamable::Model.get_current_table_name(
            table_name
          )
          self.table_structure_without_table_renamable(current_table_name)
        end
      end


      def with_retry(&block)
        # set up tries so we don't keep retrying
        tries = 0
        begin
          tries += 1
          # call the actual execute behavior
          yield
        rescue ActiveRecord::StatementInvalid => e
          # only try once
          raise e if tries > 1
          # re-raise if it's not an error we care about
          raise e unless e.message =~ /Could not find table/
          # otherwise we reload and retry
          TableRenamable::Model.reload_tables
          retry
        end
      end
    end
  end
end