module Oracle
  module Dba
    class RolePriv < ::RedmineOracle::BaseModel
      self.table_name = 'dba_role_privs'
    end
  end
end
