Rails.application.routes.draw do
  get '/current_user', to: 'current_user#index'
  devise_for :users, controllers: {
                 sessions: 'users/sessions',
                 registrations: 'users/registrations'
             }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :accounts, only: [:show, :update, :destroy, :index]
  resources :departments, only: [:create, :show, :update, :destroy, :index]
  resources :call_agendas, only: [:create, :show, :update, :destroy, :index]
  resources :call_informations, only: [:create, :show, :update, :destroy, :index]
  resources :call_types, only: [:create, :show, :update, :destroy, :index]
  resources :lead_addresses, only: [:create, :show, :update, :destroy, :index]
  resources :lead_ratings, only: [:create, :show, :update, :destroy, :index]
  resources :lead_sources, only: [:create, :show, :update, :destroy, :index]
  resources :statuses, only: [:create, :show, :update, :destroy, :index]
  # resources :leads, only: [:create, :show, :update, :destroy, :index]
  resources :potentials, only: [:create, :show, :update, :destroy, :index]
  resources :deals, only: [:create, :show, :update, :destroy, :index]
  resources :meetings, only: [:create, :show, :update, :destroy, :index]
  resources :notes, only: [:create, :show, :update, :destroy, :index]
  resources :roles, only: [:create, :show, :update, :destroy, :index]
  resources :tasks, only: [:create, :show, :update, :destroy, :index]
  get 'download_template', to: 'leads#download_template'
  resources :leads do
      collection do
        patch "update_leads"
        post "file_upload"
      end
    end
end
