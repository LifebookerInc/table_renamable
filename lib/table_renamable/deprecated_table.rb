module TableRenamable
  #
  # Class that handles the renaming of tables.  This sets the table name
  # of the class based on whether or not the table exists in the database
  #
  # @author [dlangevin]
  #
  class DeprecatedTable

    class NoTableError < Exception; end;

    # @!attribute klass
    #   @return [Class] The class whose table we are renaming
    attr_reader :klass

    # @!attribute old_name
    #   @return [Symbol] The old table name
    attr_reader :old_name

    # @!attribute new_name
    #   @return [Symbol] The new table name
    attr_reader :new_name

    #
    # Constructor - sets up the record and tries to connect to
    # the correct database
    #
    # @param  klass [Class] Class whose table we are renaming
    # @param  old_name [String, Symbol] The old table name
    # @param  new_name [String, Symbol] The new table name
    #
    def initialize(klass, old_name, new_name)
      @klass = klass
      @old_name = old_name
      @new_name = new_name
      # call to set the correct table name
      self.set_table_name
    end

    #
    # Returns the name of the table that currently exists of our
    # two options (old or new)
    #
    # @return [String] The name of the existing table
    def get_current_table_name
      [self.old_name, self.new_name].each do |name|
        return name.to_s if self.table_exists?(name)
      end
      # raise exception if we don't have a valid table
      self.raise_no_table_error
    end

    #
    # Is this table name part of our DeprecatedTable definition
    # @param  table_name [String, Symbol] Table name to chck
    #
    # @return [Boolean] Whether or not we have it in our definition
    def has_table?(table_name)
      [self.old_name, self.new_name].include?(table_name.to_sym)
    end

    #
    # Set the correct table name for the Class we are controlling
    #
    # @raise [TableRenamable::NoTableError] Error if neither name works
    #
    # @return [Boolean] True if we set the table name
    def set_table_name
      [self.old_name, self.new_name].each do |name|
        # make sure this table exists
        if self.table_exists?(name)
          # return true if we are already using this table
          return true if self.klass.table_name == name.to_s
          # otherwise we can change the table name
          self.klass.table_name = name
          return true
        end
      end
      self.raise_no_table_error
    end

    protected

    #
    # Wrapper to raise an error
    #
    # @raise [DeprecatedTable::NoTableError]
    def raise_no_table_error
      raise NoTableError.new(
        "No table for #{self.klass}.  " +
        "Tried #{self.old_name} and #{self.new_name}"
      )
    end

    #
    # Does a given table exist?
    # @param  name [String, Symbol] Table name
    #
    # @return [Boolean] Whether or not it exists
    def table_exists?(name)
      self.klass.connection.tables.include?(name.to_s)
    end


  end
end