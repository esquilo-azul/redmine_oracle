module Oracle
  module Dba
    class ConstraintColumn < ::RedmineOracle::BaseModel
      self.table_name = 'all_cons_columns'
    end
  end
end
