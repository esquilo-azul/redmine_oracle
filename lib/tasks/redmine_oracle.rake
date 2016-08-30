namespace :redmine_oracle do
  desc 'Mostra a versão do servidor Oracle'
  task server_version: [:environment] do
    c = ::RedmineOracle::Connection.connection.execute('select * from v$version')
    loop do
      r = c.fetch
      break unless r
      puts r.join(' | ')
    end
  end

  desc 'Pesquisa por valor em todas as tabelas/colunas do Oracle'
  task :search_values, [:column_type, :value] => :environment do |_t, args|
    RedmineOracle::SearchValues.new([args.column_type], [args.value]).run
  end
end
