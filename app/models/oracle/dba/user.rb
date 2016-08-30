require 'sjap/oracle'

module Oracle
  module Dba
    class User < ::RedmineOracle::BaseModel
      self.table_name = 'dba_users'

      def granted_role?(role)
        granted_roles.include?(role)
      end

      def granted_roles
        @granted_roles ||= ::Sjap::Oracle.map(<<EOS
SELECT GRANTED_ROLE
FROM DBA_ROLE_PRIVS
WHERE lower(grantee) = lower('#{username}')
EOS
                                             ) do |row|
          row[0]
        end
      end
    end
  end
end
