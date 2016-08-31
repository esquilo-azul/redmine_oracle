module RedmineOracle
  module EnhancedModel
    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def oracle_belongs_to(name, class_name, options = {})
        associations[name] = BelongsToAssociation.new(self, class_name, options)
      end

      def oracle_has_many(name, class_name, options = {})
        associations[name] = HasManyAssociation.new(self, class_name, options)
      end

      def oracle_has_one(name, class_name, options = {})
        associations[name] = HasOneAssociation.new(self, class_name, options)
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
    end

    def method_missing(name, *args, &block)
      assoc = self.class.find_association(name)
      assoc ? assoc.instance_value(self) : super
    end

    def respond_to_missing?(name, include_private = false)
      self.class.find_association(name) ? true : super
    end
  end
end
