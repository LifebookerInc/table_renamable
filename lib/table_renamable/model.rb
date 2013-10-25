module TableRenamable
  #
  # Model that is included in ActiveRecord to enable our behavior
  #
  # @author [dlangevin]
  #
  module Model

    extend ActiveSupport::Concern

    class NoTableError < Exception; end;


    included do |klass|
      klass.class_attribute :deprecated_columns
      klass.deprecated_columns = []
    end


    #
    # Return our list of deprecated tables
    #
    # @return [Array<DeprecatedTable>] Our list of deprecated tables
    def self.deprecated_tables
      @deprecated_tables ||= []
    end

    #
    # Update a string of SQL to replace deprecated tables
    # @param  sql [String] SQL TO update
    #
    # @return [String] Updated SQL
    def self.process_sql(sql)
      self.deprecated_tables.each do |deprecated_table|
        # our current table name
        current_table_name = deprecated_table.get_current_table_name
        old_table_name = deprecated_table.old_name
        sql = sql.gsub(/#{old_table_name}/, current_table_name.to_s)
      end
      sql
    end

    #
    # Reload our table names so we pick up any changes
    #
    # @return [Boolean] Always true
    def self.reload_tables
      self.deprecated_tables.each(&:set_table_name)
      true
    end

    #
    # ClassMethods to be mixed in to the model using this behavior
    #
    # @author [dlangevin]
    #
    module ClassMethods

      #
      # Overrides columns to remove deprecated columns
      #
      # @return [Array<>] Filtered array of columns
      def columns
        super.reject { |column|
          self.deprecated_columns.include?(column.name)
        }
      end

      #
      # Mark columns as deprecated
      # @param  *column_names [Array<String, Symbol>] Column names
      #
      # @return [Array<String>] List of deprecated columns
      def deprecate_columns(*column_names)
        self.deprecated_columns =
          self.deprecated_columns + Array.wrap(column_names).collect(&:to_s)
      end

      #
      # Mark this class as having a potentially new table name
      # @param  old_name [String, Symbol] The old table name
      # @param  new_name [String, Symbol] The new table name
      #
      # @return [TableRenamable::DeprecatedTable] The newly
      # created TableRenamable::DeprecatedTable records
      def deprecate_table_name(old_name, new_name)
        deprecated_table = DeprecatedTable.new(self, old_name, new_name)
        TableRenamable::Model.deprecated_tables << deprecated_table
        deprecated_table
      end

    end

  end
end