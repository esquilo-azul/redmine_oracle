module RedmineOracle
  class BaseModel < ActiveRecord::Base
    include ::RedmineOracle::EnhancedModel
    include ::Eac::SimpleCache
    establish_connection :oracle

    self.abstract_class = true

    def data_import_key
      attrs = self.class.pk_constraint.columns_names.sort.map do |c|
        attr = c.downcase.to_sym
        [attr, self[attr]]
      end
      attrs.to_h.to_yaml
    end

    def self.parse_data_import_key(key)
      YAML.load(key)
    end
  end
end
