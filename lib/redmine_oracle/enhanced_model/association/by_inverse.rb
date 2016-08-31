module RedmineOracle
  module EnhancedModel
    class Association
      module ByInverse
        protected

        def inverse
          @inverse ||= begin
            return nil unless @options[:inverse_of].present?
            r = target_class.find_association(@options[:inverse_of])
            return r if r
            fail "Associação \"#{@options[:inverse_of]}\" não encontrada em #{target_class}"
          end
        end

        def by_inverse_source_columns
          inverse.target_columns
        end

        def by_inverse_target_columns
          inverse.source_columns
        end
      end
    end
  end
end
