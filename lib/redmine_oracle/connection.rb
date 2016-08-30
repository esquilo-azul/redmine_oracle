module RedmineOracle
  module Connection
    class << self
      def connection
        ::RedmineOracle::BaseModel.connection
      end

      def execute(sql)
        execute!(sql)
        false
      rescue ActiveRecord::StatementInvalid => ex
        ex.to_s
      end

      def execute!(sql)
        connection.execute(sql)
      end

      def query_unique_value(sql)
        c = connection.execute(sql)
        loop do
          r = c.fetch
          break unless r
          return r[0]
        end
        nil
      end

      def each(sql, &block)
        fail 'Bloco não fornecido' unless block
        c = ::RedmineOracle::Connection.connection.execute(sql)
        loop do
          row = c.fetch
          break unless row
          block.call(row)
        end
      end

      def unique_row(sql)
        each(sql) do |r|
          return r
        end
        nil
      end

      def map(sql, &block)
        r = []
        each(sql) do |row|
          r << block.call(row)
        end
        r
      end
    end
  end
end
