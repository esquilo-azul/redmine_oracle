require 'redmine_oracle/connection'

module Oracle
  module Dba
    class User < ::RedmineOracle::BaseModel
      self.table_name = 'dba_users'

      class << self
        def find(id)
          find_by_login(id)
        end

        def find_by_login(login)
          where('lower(username) = lower(?)', login).first
        end
      end

      def granted_role?(role)
        granted_roles.include?(role)
      end

      has_many :roles, class_name: '::Oracle::Dba::RolePriv', primary_key: :username,
                       foreign_key: :grantee

      scope :real, lambda {
        where("REGEXP_LIKE(username, '^[A-Z]{2}[0-9]+')")
      }

      def to_s
        username
      end

      def id
        username
      end

      def granted_roles
        ::RedmineOracle::Connection.map(<<EOS) do |row|
SELECT GRANTED_ROLE
FROM DBA_ROLE_PRIVS
WHERE lower(grantee) = lower('#{username}')
EOS
          row[0]
        end
      end

      def password_match?(pwd)
        ::RedmineOracle::UserPasswordMatch.authenticate(username, pwd)
      end
    end
  end
end
