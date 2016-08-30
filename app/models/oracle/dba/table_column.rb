module Oracle
  module Dba
    class TableColumn < Sjap::Oracle::BaseModel
      self.table_name = 'dba_tab_columns'
    end
  end
end
