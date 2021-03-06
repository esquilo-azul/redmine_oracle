module Oracle
  module Dba
    class Constraint < ::RedmineOracle::BaseModel
      self.table_name = 'all_constraints'

      def to_s
        [owner, constraint_name].join('.')
      end

      def columns
        ::Oracle::Dba::ConstraintColumn.where(owner: owner, constraint_name: constraint_name).order(
          position: :asc, column_name: :asc)
      end

      def columns_names
        @columns_names ||= columns.pluck(:column_name)
      end

      def reverse
        @reverse ||= begin
          return nil unless r_constraint_name
          r = ::Oracle::Dba::Constraint.where(owner: r_owner,
                                              constraint_name: r_constraint_name).first
          return r if r
          fail "Reverse constraint not found for #{self}" \
            "(Owner: \"#{r_owner}\", Name: \"#{r_constraint_name}\""
        end
      end

      def reverse_constraints
        ::Oracle::Dba::Constraint.where(r_owner: owner, r_constraint_name: constraint_name)
      end

      def table
        ::Oracle::Dba::Table.by_owner_and_name(owner, table_name)
      end

      class << self
        def instance_method_already_implemented?(method_name)
          return true if method_name == 'invalid?'
          super
        end
      end
    end
  end
end
