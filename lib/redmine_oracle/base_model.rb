module RedmineOracle
  class BaseModel < ActiveRecord::Base
    include ::RedmineOracle::EnhancedModel
    include ::Eac::SimpleCache
    establish_connection :oracle

    self.abstract_class = true

    def id
      attrs = self.class.pk_constraint.columns_names.sort.map do |c|
        attr = c.downcase.to_sym
        [attr, self[attr]]
      end
      attrs.to_h.to_yaml
    end

    def self.parse_id(key)
      YAML.load(key)
    end
  end
end
