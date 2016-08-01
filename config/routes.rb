RedmineApp::Application.routes.draw do
  match 'oracle_schema', to: 'oracle_schema#index', via: [:get, :post], as: 'oracle_schema'
end
