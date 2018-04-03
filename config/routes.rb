Rails.application.routes.draw do

  devise_for :users, path: 'usr', controllers: {
        registrations: 'users/registrations',
        omniauth_callbacks: 'users/omniauth_callbacks'
      }
  resources :users, only: [:show, :index, :update] do
    collection do
      get "choose_profile"
      get "home"
      get "activity_feed"
      get "chrip_feed"
      get "track_feed"
      get "artist_feed"
      post "change_avatar"
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
  
  get 'about', to: 'home#about'

  resources :contacts, only: [:index, :create]
  resources :slider_images
  resources :releases, only: [:show, :index]
  resources :tracks
  resources :topics # TODO remove it 
  resources :posts do
    get 'reply_form'
  end
  resources :follows
  resources :comments
  resources :likes

  resources :chirp, controller: 'topic_categories' do
    # get 'category/:id', to: "topics#category"
    resources :topics
    # get 'pin'
    # get 'unpin'
    # get 'lock'
    # get 'unlock'
  end

  root "home#index"


  
  post 'demo_drop/:id', to: 'home#demo_drop', as: 'demo_drop'
  get 'demo', to: 'home#demo_index'
  post 'demo_login', to: 'home#demo_login'
  get 'demo_get_100/:id', to: 'home#demo_get_100_points', as: "demo_get_100"
end
