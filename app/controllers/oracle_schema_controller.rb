class OracleSchemaController < ApplicationController
  layout 'sjap'
  require_permission 'oracle_schema_read'

  def index
    generate_cache_file if request.post?
    if File.exist?(cache_file)
      @cache_time = File.mtime(cache_file)
      @content = File.read(cache_file)
    else
      @cache_time = nil
      @content = nil
    end
  end

  private

  def generate_cache_file
    @tables = ::Oracle::Dba::Table.order(owner: :asc, table_name: :asc)
    File.write(cache_file, render_to_string('content', layout: false))
  end

  def cache_file
    @cache_file ||= Rails.root.join('tmp', 'cache', 'oracle_schema.html')
  end
end
