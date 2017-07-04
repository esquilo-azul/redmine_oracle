module RedmineOracle
  module EnhancedModel
    class BelongsToAssociation < Association
      def instance_value_read(instance)
        target_query_relation(instance).first
      end

      def instance_value_write(instance, target_instance)
        check_foreign_key
        if target_instance.nil?
          instance_value_write_nil(instance)
        elsif target_instance.is_a?(target_class)
          instance_value_write_target_instance(instance, target_instance)
        else
          fail "Value is not nil neither a #{target_class} instance (#{instance.class})"
        end
        target_instance
      end

      def where_by_target(target_instance)
        source_query_relation(target_instance)
      end

      private

      def instance_value_write_nil(instance)
        source_columns.each { |c| instance[c] = nil }
      end

      def instance_value_write_target_instance(instance, target_instance)
        fail 'Target instance has no all required columns' unless
        instance_has_target_column_values(target_instance)
        source_columns.each_with_index do |c, i|
          instance[c] = target_instance[target_columns[i]]
        end
      end

      def foreign_key_in_source?
        true
      end
    end
  end
end
