require 'sjap/oracle'

module RedmineOracle
  class SearchValues
    def initialize(column_types, values)
      @types = column_types
      @values = values
      @exclude_owners = %w(SYS SYSTEM XDB)
    end

    def run
      Rails.logger.info "Procurando colunas do(s) tipo(s) #{@types}..."
      columns = columns_to_search
      Rails.logger.info "Colunas encontradas: #{columns.length}"
      process_columns(columns)
    end

    private

    def process_columns(columns)
      bar = RakeProgressbar.new(columns.length)
      columns.each do |c|
        @values.each { |v| search_in_column(c[:table], c[:column], v) }
        bar.inc
      end
      bar.finished
    end

    def columns_to_search
      r = []
      tables_to_search.each do |t|
        t.columns.each do |c|
          next unless @types.include?(c.data_type)
          r << { table: t.to_s, column: c.column_name }
        end
      end
      r
    end

    def tables_to_search
      ::Oracle::Dba::Table.where.not(owner: @exclude_owners)
    end

    def search_in_column(table_fullname, column_name, value)
      found = search_column_count(table_fullname, column_name, value)
      return unless found > 0
      Rails.logger.info "Column: #{table_fullname}.#{column_name}, Value: #{value}, " \
        "Found: #{found.to_i}"
    end

    def search_column_count(table_fullname, column_name, value)
      ::Sjap::Oracle.query_unique_value(<<EOS)
select count(#{column_name})
from #{table_fullname}
where #{column_name} = #{value}
EOS
    end
  end
end
