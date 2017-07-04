module RedmineOracle
  module EnhancedModel
    class BelongsToAssociation < Association
      def instance_value_read(instance)
        target_query_relation(instance).first
      end

      def where_by_target(target_instance)
        source_query_relation(target_instance)
      end

      private

      def foreign_key_in_source?
        true
      end
    end
  end
end
