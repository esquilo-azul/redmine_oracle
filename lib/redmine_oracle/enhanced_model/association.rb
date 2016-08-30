module RedmineOracle
  module EnhancedModel
    class Association
      def initialize(source_class, class_name, options = {})
        @source_class = source_class
        @target_class_name = class_name
        @options = ActiveSupport::HashWithIndifferentAccess.new(options)
      end

      protected

      def query_relation(instance)
        check_foreign_key
        return target_class.none unless instance_has_source_column_values(instance)
        q = target_class.all
        target_columns.each_with_index do |c, i|
          q = q.where(c => instance[source_columns[i]])
        end
        order_query(q)
      end

      def to_s
        "Source: #{@source_class.name}, Target name: #{@target_class_name}"
      end

      private

      def order_query(q)
        order_fields.each do |field, orientation|
          q = q.order(field => orientation)
        end
        q
      end

      def order_fields
        return {} unless @options[:order]
        @options[:order]
      end

      def instance_has_source_column_values(instance)
        source_columns.all? { |c| instance[c].present? }
      end

      def source_columns
        @source_columns ||= begin
          return by_constraint_source_columns if constraint.present?
          fail 'No source columns provided'
        end
      end

      def target_columns
        @target_columns ||= begin
          return by_constraint_target_columns if constraint.present?
          fail 'No target columns provided'
        end
      end

      def foreign_key_class
        foreign_key_in_source? ? @source_class : target_class
      end

      def check_foreign_key
        return if @foreign_key_checked
        check_constraint_type
        check_constraint_owner
        check_columns(@source_class, source_columns)
        check_columns(target_class, target_columns)
        @foreign_key_checked = true
      end

      def check_columns(klass, columns)
        columns.each do |c|
          fail "#{klass} nao possui coluna \"#{c}\" (Associação: #{self}, " \
            "Colunas: #{klass.column_names}))" unless
          klass.column_names.include?(c)
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

      def target_class
        @target_class ||= @target_class_name.constantize
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
