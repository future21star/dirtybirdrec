Rails.application.routes.draw do

  devise_for :users, controllers: { registrations: "registrations" }#, ActiveAdmin::Devise.config
  resources :users, only: [:show, :index, :update] do
    collection do
      get "choose_profile"
      get "home"
      get "activity_feed"
      get "chrip_feed"
      get "track_feed"
      get "artist_feed"
    end
  end
  ActiveAdmin.routes(self)

  devise_scope :user do
    authenticated do
      root 'users#home', as: :authenticated_root
    end
  end
  
  get 'artists/:id', to: 'users#artist', as: 'artist'
  get 'artists', to: 'users#artists', as: 'artists'
  get 'chrip', to: 'home#chrip', as: 'chrip'
  
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
