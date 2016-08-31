module RedmineOracle
  module EnhancedModel
    class Association
      include ::RedmineOracle::EnhancedModel::Association::ByConstraint
      include ::RedmineOracle::EnhancedModel::Association::ByInverse

      def initialize(source_class, class_name, options = {})
        @source_class = source_class
        @target_class_name = class_name
        @options = ActiveSupport::HashWithIndifferentAccess.new(options)
      end

      def source_columns
        @source_columns ||= begin
          return by_inverse_source_columns if inverse.present?
          return by_constraint_source_columns if constraint.present?
          return provided_source_columns if provided_source_columns.present?
          fail 'No source columns provided'
        end
      end

      def target_columns
        @target_columns_cached ||= begin
          return by_inverse_target_columns if inverse.present?
          return by_constraint_target_columns if constraint.present?
          return by_primary_key_target_columns if provided_source_columns.present?
          fail 'No target columns provided'
        end
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

      def foreign_key_class
        foreign_key_in_source? ? @source_class : target_class
      end

      def check_columns(klass, columns)
        columns.each do |c|
          fail "#{klass} nao possui coluna \"#{c}\" (Associação: #{self}, " \
            "Colunas: #{klass.column_names}))" unless
          klass.column_names.include?(c)
        end
      end

      def target_class
        @target_class ||= @target_class_name.constantize
      end

      def provided_source_columns
        return nil unless @options[:source_columns].present?
        return [@options[:source_columns]] unless @options[:source_columns].is_a?(Array)
        @options[:source_columns]
      end

      def by_primary_key_target_columns
        target_class.pk_constraint.columns_names.map(&:underscore)
      end
    end
  end
end
