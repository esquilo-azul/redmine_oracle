module Oracle
  module Dba
    class TableColumn < ::RedmineOracle::BaseModel
      self.table_name = 'dba_tab_columns'
    end
  end
end
