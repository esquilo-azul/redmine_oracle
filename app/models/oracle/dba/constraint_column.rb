module Oracle
  module Dba
    class ConstraintColumn < Sjap::Oracle::BaseModel
      self.table_name = 'dba_cons_columns'
    end
  end
end
