module RedmineOracle
  module EnhancedModel
    class HasOneAssociation < Association
      def instance_value(instance)
        query_relation(instance).first
      end

      private

      def foreign_key_in_source?
        false
      end
    end
  end
end
