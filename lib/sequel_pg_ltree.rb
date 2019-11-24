require "sequel_pg_ltree/version"
require 'sequel'

# Sequel: The Database Toolkit for Ruby
module Sequel
  # Sequel Plugins - http://sequel.jeremyevans.net/plugins.html
  module Plugins
    # The Sequel::PgLtree model plugin
    #
    # @example Simple usage
    #
    #     require 'sequel-pg-ltree'
    #     Document.plugin Sequel::PgLtree
    #
    module PgLtree
      # Apply the model instance
      #
      # @param [object] model
      # @param [OPTS] _opts
      #
      # @return void
      def self.apply(model, _opts = OPTS)
        model.instance_eval do
          plugin :dirty
        end
      end

      # Plugin configuration
      #
      # @param [object] model
      # @param [hash] options
      #
      # @return object
      def self.configure(model, options = {})
        model.instance_eval do
          @column = options.fetch(:column, nil)
          @cascade = options.fetch(:cascade, true)
        end

        model
      end

      module ClassMethods
        attr_reader :column

        Plugins.inherited_instance_variables(self, :@column => nil)
      end

      module InstanceMethods
        # Plugin configuration
        #
        # @return class
        def scope
          self.class
        end

        # Ltree column name
        #
        # @return [string]
        def ltree_column
          scope.column
        end

        # Model table name
        #
        # @return [string]
        def table_name
          scope.table_name
        end

        # Fetch ltree path value
        #
        # @return [string]
        def ltree_path
          public_send scope.column
        end

        # Fetch node level
        #
        # @return [integer]
        def nlevel
          scope.select(Sequel.lit("NLEVEL(?)", ltree_path).as(:count)).where(id: 2).first[:count]
        end

        # Fetch node root
        #
        # @return [object] root
        def root
          scope.where(Sequel.lit("#{table_name}.#{ltree_column} = SUBPATH(?, 0, 1)", ltree_path)).first
        end

        # Fetch parent of the node
        #
        # return [object] parent
        def parent
          scope.where(Sequel.lit("#{table_name}.#{ltree_column} = SUBPATH(?, 0, NLEVEL(?) - 1)", ltree_path, ltree_path)).first
        end

        # Fetch children
        #
        # @return [array]
        def children
          scope.where(Sequel.lit("? @> #{table_name}.#{ltree_column} AND nlevel(#{table_name}.#{ltree_column}) = NLEVEL(?) + 1",
                                 ltree_path, ltree_path))
        end

        # Fetch self and descendants
        #
        # @return [array]
        def self_and_descendants
          scope.where(Sequel.lit("#{table_name}.#{ltree_column} <@ ?", ltree_path))
        end

        # Fetch descendants without self
        #
        # @return [array]
        def descendants
          self_and_descendants.where(Sequel.lit("#{table_name}.#{ltree_column} != '#{ltree_path}'"))
        end

        # Fetch self and siblings
        #
        # @return [array]
        def self_and_siblings
          scope.where(
              Sequel.lit("SUBPATH(?, 0, NLEVEL(?) - 1) @> #{table_name}.#{ltree_column} AND nlevel(#{table_name}.#{ltree_column}) = NLEVEL(?)",
                         ltree_path, ltree_path, ltree_path)
          )
        end

        # Fetch siblings without self
        #
        # @return [array]
        def siblings
          self_and_siblings.where(Sequel.lit("#{table_name}.#{ltree_column} != '#{ltree_path}'"))
        end

        # Fetch self and ancestors
        #
        # @return [array]
        def self_and_ancestors
          scope.where(Sequel.lit("#{table_name}.#{ltree_column} @> ?", ltree_path))
        end

        # Fetch ancestors without self
        #
        # @return [array]
        def ancestors
          self_and_ancestors.where(Sequel.lit("#{table_name}.#{ltree_column} != '#{ltree_path}'"))
        end

        # After update hook
        #
        # @return [boolean]
        def after_update
          super

          if column_changed?(ltree_column.to_sym)
            old_value = column_change(:path)[0]
            scope
                .where(Sequel.lit("tree.path <@ ? AND tree.path != ?", old_value, ltree_path))
                .update("#{ltree_column}" => Sequel.lit("'#{ltree_path}' || SUBPATH(path, NLEVEL('#{old_value}'))"))
          end
        end

        # After destroy hook
        # Works only with destroy, not with delete
        #
        # @return [boolean]
        def after_destroy
          scope.where(Sequel.lit("#{table_name}.#{ltree_column} <@ ?", ltree_path)).delete
        end
      end
    end
  end
end

