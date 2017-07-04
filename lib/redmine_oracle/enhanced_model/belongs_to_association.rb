module RedmineOracle
  module EnhancedModel
    class BelongsToAssociation < Association
      def instance_value_read(instance)
        target_query_relation(instance).first
      end

      private

      def foreign_key_in_source?
        true
      end
    end
  end
end
