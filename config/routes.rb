Rails.application.routes.draw do

  devise_for :users, controllers: { registrations: "registrations" }#, ActiveAdmin::Devise.config
  resources :users, only: [:show, :index, :update] do
    collection do
      get "choose_profile"
      get "home"
    end
  end
  ActiveAdmin.routes(self)

  devise_scope :user do
    authenticated do
      root 'users#home', as: :authenticated_root
    end
  end
  
  get 'about', to: 'home#about'

  resources :contacts, only: [:index, :create]
  resources :slider_images
  resources :releases, only: [:show, :index]
  resources :tracks
  resources :topics
  resources :posts
  resources :follows
  resources :comments
  resources :likes

  root "home#index"


  
  post 'demo_drop/:id', to: 'home#demo_drop', as: 'demo_drop'
  get 'demo', to: 'home#demo_index'
  post 'demo_login', to: 'home#demo_login'
end
