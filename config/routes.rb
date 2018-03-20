Rails.application.routes.draw do
  devise_for :users#, ActiveAdmin::Devise.config
  resources :users, :only =>[:show]
  ActiveAdmin.routes(self)

  mount Thredded::Engine => '/forum'

  devise_scope :user do
    unauthenticated do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end
  
  root "home#index"
  
  get "home", to: "home#index"

  get 'about', to: 'home#about'

  resources :contacts, only: [:index, :create]
  resources :slider_images
  resources :releases
  resources :tracks
  resources :topics
  resources :posts
  resources :follows
  resources :comments
  resources :likes

  get 'demo', to: 'home#demo_index'
  post 'demo_login', to: 'home#demo_login'
end
