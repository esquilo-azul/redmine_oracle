module RedmineOracle
  module EnhancedModel
    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def oracle_belongs_to(name, class_name, options = {})
        associations[name] = BelongsToAssociation.new(self, class_name, options)
        define_instance_read_method(name)
        define_instance_write_method(name)
        define_singleton_method("where_#{name}") do |target_instance|
          associations[name].where_by_target(target_instance)
        end
      end

      def oracle_has_many(name, class_name, options = {})
        associations[name] = HasManyAssociation.new(self, class_name, options)
        define_instance_read_method(name)
      end

      def oracle_has_one(name, class_name, options = {})
        associations[name] = HasOneAssociation.new(self, class_name, options)
        define_instance_read_method(name)
      end

      def find_association(name)
        associations[name]
      end

      def table
        @table ||= ::Oracle::Dba::Table.where(owner: table_name_parts[0],
                                              table_name: table_name_parts[1]).first
      end

      def pk_constraint
        c = ::Oracle::Dba::Constraint.where(owner: table.owner, table_name: table.table_name,
                                            constraint_type: 'P').first
        return c if c
        "\"#{table}\" has no primary key constraint"
      end

      private

      def table_name_parts
        @parts ||= begin
          parts = table_name.split('.')
          unless parts.length == 2
            fail "Nome de tabela não tem duas partes (<owner>.<table_name>): #{table_name}"
          end
          parts.map(&:upcase)
        end
      end

      def associations
        @associations ||= ActiveSupport::HashWithIndifferentAccess.new
      end

      def define_instance_read_method(assoc_name)
        define_method(assoc_name) do
          assoc = self.class.find_association(assoc_name)
          return super unless assoc
          @assoc_cache ||= ActiveSupport::HashWithIndifferentAccess.new
          @assoc_cache[assoc_name] ||= assoc.instance_value_read(self)
        end
      end

      def define_instance_write_method(assoc_name)
        define_method("#{assoc_name}=") do |value|
          assoc = self.class.find_association(assoc_name)
          return super unless assoc
          @assoc_cache ||= ActiveSupport::HashWithIndifferentAccess.new
          @assoc_cache[assoc_name] ||= assoc.instance_value_write(self, value)
        end
      end
    end
  end
end
