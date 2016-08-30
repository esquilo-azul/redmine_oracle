module RedmineOracle
  class BaseModel < ActiveRecord::Base
    include ::RedmineOracle::EnhancedModel
    establish_connection :oracle

    self.abstract_class = true

    def reloadable(key, &block)
      key = key.to_s
      return reloadable_data[key] if reloadable_data.key?(key)
      reloadable_data[key] = block.call
    end

    private

    def reloadable_data
      @reloadable_data ||= {}
    end

    def reload
      reloadable_data.clear
      super
    end
  end
end
