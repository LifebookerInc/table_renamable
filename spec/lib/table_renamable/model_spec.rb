require 'spec_helper'

module TableRenamable

  describe Model do

    before(:each) do

      Post.table_name = 'posts'

      Post.connection.create_table :posts, force: true do |t|
        t.string :title
        t.string :body
        t.integer :user_id
        t.timestamps
      end
      Post.reset_column_information

      Post.connection.execute("DROP TABLE IF EXISTS my_new_name")


      # users
      User.connection.create_table :users, force: true do |t|
        t.string :name
        t.string :description
        t.timestamps
      end

    end

    context 'with table rename' do

      before(:each) do
        # only do this once but it has to happen after the table is defined
        unless Post.included_modules.include?(TableRenamable::Model)
          Post.class_eval do

            include TableRenamable::Model

            deprecate_table_name(:posts, :my_new_name)
          end
        end
      end

      context '.deprecate_table_name' do

        it 'allows tables to be renamed without missing a beat' do

          Post.connection.rename_table(:posts, :my_new_name)

          lambda { Post.all }.should_not raise_error

        end

      end
    end

    context '.deprecate_columns' do


      it 'allows columns to be renamed without throwing errors' do
        # need to call this to get the columns loaded
        User.all


        User.class_eval do

          include TableRenamable::Model

          deprecate_columns(:name)
        end

        User.columns.collect(&:name).should_not include "name"
        User.column_names.should_not include "name"

      end

    end

  end

end