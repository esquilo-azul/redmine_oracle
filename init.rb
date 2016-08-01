# coding: utf-8

require 'redmine'

Redmine::Plugin.register :redmine_oracle do
  name 'Redmine Oracle'
  author 'TRF1 - SJAP - SEINF'
  description 'Conector para o Oracle'
  version '0.0.1'
  url 'http://172.18.4.200/redmine/projects/redmine'
  author_url 'http://172.18.4.200/redmine/projects/seinf-ap'

  Redmine::MenuManager.map :redmine_oracle do |menu|
    menu.push :oracle_schema, { controller: 'oracle_schema', action: 'index' },
              caption: :label_oracle_schema,
              if: proc { GroupPermission.permission?('oracle_schema_read') }
  end
end

Rails.configuration.to_prepare do
  GroupPermission.add_permission('oracle_schema_read')
end
