module RedmineOracle
  class BaseModel < ActiveRecord::Base
    include ::RedmineOracle::EnhancedModel
    include ::Eac::SimpleCache
    establish_connection :oracle

    self.abstract_class = true

    class << self
      def find(id)
        return super if primary_key.present?
        h = YAML.load(id)
        fail "ID \"#{h}\" is not a Hash" unless h.is_a?(Hash)
        find_by_pk_columns(h) || fail("Not found with #{h}")
      end

      def pk_columns
        pk_constraint.columns_names.sort.map { |c| c.downcase.to_sym }
      end

      private

      def find_by_pk_columns(attrs)
        attrs = attrs.with_indifferent_access
        q = all
        pk_columns.each do |c|
          fail "#{c} is blank (#{attrs})" if attrs[c].blank?
          q = q.where(c => attrs[c])
        end
        q.first
      end
    end

    # Models com chaves primárias de um único campo sobreescrevem este método.
    def id
      attrs = self.class.pk_columns.map { |attr| [attr, self[attr]] }
      attrs.to_h.to_yaml
    end

    def self.parse_id(key)
      if primary_key.present?
        { primary_key => key }.with_indifferent_access
      else
        YAML.load(key)
      end
    end
  end
end
