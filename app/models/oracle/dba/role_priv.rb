module Oracle
  module Dba
    class RolePriv < ::RedmineOracle::BaseModel
      self.table_name = 'all_role_privs'
    end
  end
end
