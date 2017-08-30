module Oracle
  module Dba
    class TableColumn < ::RedmineOracle::BaseModel
      self.table_name = 'all_tab_columns'
    end
  end
end
