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

      def with_default_transaction(&block)
        ActiveRecord::Base.transaction do
          on_oracle_database_transaction(&block)
        end
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

      def on_oracle_database_transaction(&block)
        rollback = nil
        transaction do
          begin
            block.call
          rescue ActiveRecord::Rollback => ex
            rollback = ex
            raise ActiveRecord::Rollback
          end
        end
        fail rollback if rollback
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

    def relation_for_destroy
      d = Hash[self.class.pk_columns.map { |c| [c, self[c]] }]
      r = self.class.where(d)
      return r if r.count <= 1
      fail "Relation for destroy count is greater then 1 (Count: #{r.count}, Data: #{d})"
    end
  end
end
