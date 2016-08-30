module Oracle
  module Dba
    class Table < Sjap::Oracle::BaseModel
      self.table_name = 'dba_tables'

      def to_s
        [owner, table_name].join('.')
      end

      def columns
        ::Oracle::Dba::TableColumn.where(owner: owner, table_name: table_name)
          .order(column_name: :asc)
      end

      def constraints
        @constraints ||= ::Oracle::Dba::Constraint.where(owner: owner, table_name: table_name)
                         .where.not(constraint_type: 'C')
                         .order(constraint_type: :asc, constraint_name: :asc)
      end

      def reverse_constraints
        @reverse_constraints ||= constraints.flat_map(&:reverse_constraints)
                                 .sort_by { |e| [e.owner, e.table_name, e.constraint_name] }
      end

      def owner_equal?(other)
        return false unless other.is_a?(self.class)
        owner.to_s.upcase == other.owner.to_s.upcase
      end

      def ==(other)
        owner_equal?(other) && table_name.to_s.upcase == other.table_name.to_s.upcase
      end

      def self.by_owner_and_name(owner, table_name)
        where('upper(owner) = upper(?) and upper(table_name) = upper(?)',
              owner, table_name).first
      end
    end
  end
end
