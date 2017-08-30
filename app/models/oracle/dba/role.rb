module Oracle
  module Dba
    class Role < ::RedmineOracle::BaseModel
      self.table_name = 'all_roles'

      def self.names
        all.pluck(:role)
      end
    end
  end
end
