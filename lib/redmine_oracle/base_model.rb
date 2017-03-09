module RedmineOracle
  class BaseModel < ActiveRecord::Base
    include ::RedmineOracle::EnhancedModel
    include ::Eac::SimpleCache
    establish_connection :oracle

    self.abstract_class = true

    # Models com chaves primárias de um único campo sobreescrevem este método.
    def id
      attrs = self.class.pk_constraint.columns_names.sort.map do |c|
        attr = c.downcase.to_sym
        [attr, self[attr]]
      end
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
