module RedmineOracle
  module EnhancedModel
    class Association
      module ByConstraint
        protected

        def check_foreign_key
          return unless constraint.present?
          return if @foreign_key_checked
          check_constraint_type
          check_constraint_owner
          check_columns(@source_class, by_constraint_source_columns)
          check_columns(target_class, by_constraint_target_columns)
          @foreign_key_checked = true
        end

        def constraint
          @constraint ||= begin
            return nil unless @options[:constraint_name].present?
            c = ::Oracle::Dba::Constraint.where(owner: foreign_key_class.table.owner,
                                                constraint_name: @options[:constraint_name]).first
            return c if c
            fail "Constraint not found: owner: \"#{foreign_key_class.table.owner}\", " \
              "name: \"#{@options[:constraint_name]}\""
          end
        end

        def check_constraint_type
          fail "Nenhuma coluna encontrada para #{constraint}" if constraint.columns.empty?
          fail "\"#{constraint}\" não é chave estrangeira" unless constraint.constraint_type == 'R'
        end

        def check_constraint_owner
          return if constraint.table == foreign_key_class.table
          fail "Constraint: #{constraint}, Foreign Key Class Table: " \
            "#{foreign_key_class.table}, Constraint Table: #{constraint.table}"
        end

        def by_constraint_source_columns
          if foreign_key_in_source?
            constraint.columns_names
          else
            constraint.reverse.columns_names
          end.map(&:downcase)
        end

        def by_constraint_target_columns
          if foreign_key_in_source?
            constraint.reverse.columns_names
          else
            constraint.columns_names
          end.map(&:downcase)
        end
      end
    end
  end
end
