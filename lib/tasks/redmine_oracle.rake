namespace :redmine_oracle do
  desc 'Pesquisa por valor em todas as tabelas/colunas do Oracle'
  task :search_values, [:column_type, :value] => :environment do |_t, args|
    RedmineOracle::SearchValues.new([args.column_type], [args.value]).run
  end
end
