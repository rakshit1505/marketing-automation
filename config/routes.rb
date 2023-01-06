Rails.application.routes.draw do
  get '/current_user', to: 'current_user#index'
  devise_for :users, controllers: {
                 sessions: 'users/sessions',
                 registrations: 'users/registrations'
             }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :accounts, only: [:show, :update, :destroy, :index]
  resources :departments, only: [:create, :show, :update, :destroy, :index]
end
