module RedmineOracle
  module EnhancedModel
    class HasManyAssociation < Association
      def instance_value_read(instance)
        target_query_relation(instance)
      end

      private

      def foreign_key_in_source?
        false
      end
    end
  end
end
