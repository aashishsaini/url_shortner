Rails.application.routes.draw do
  root to: 'shortend_urls#index'
  get '/:short_url', to: 'shortend_urls#show'
  get 'shortend/:short_url', to: 'shortend_urls#shortend', as: :shortend
  post 'shortend_urls/create'
  get 'shortend_urls/create', to: 'shortend_urls#index'
  get 'shortend_urls/fetch_original_url'
end
