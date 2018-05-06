Rails.application.routes.draw do
  
  devise_for :users, path: 'usr', controllers: {
        registrations: 'users/registrations',
        omniauth_callbacks: 'users/omniauth_callbacks'
      }

  resources :users, only: [:show, :index, :update] do
    collection do
      post "change_avatar"
    end
  end

  post '/rate' => 'rater#create', :as => 'rate'
  get "leaderboard", to: "users#leaderboard"
  get "choose_profile", to: "users#choose_profile"
  get "home", to: "users#home"
  # get "activity_feed", to: "users#activity_feed"
  get "chirp_feed", to: "users#chirp_feed"
  get "release_feed", to: "users#release_feed"
  get "artist_feed", to: "users#artist_feed"
  get "announcement_feed", to: "users#announcement_feed"
  get "interviews_feed/:id", to: "users#interviews_feed", as: "interviews_feed"
  get "videos_feed/:id", to: "users#videos_feed", as: "videos_feed"
  get "others_feed/:id", to: "users#others_feed", as: "others_feed"
  get "friends/:id", to: "users#friends", as: "friends"
  get "idols/:id", to: "users#idols", as: "idols"

  ActiveAdmin.routes(self)

  devise_scope :user do
    authenticated do
      root 'users#home', as: :authenticated_root
    end
  end
  
  get 'artists/:id', to: 'users#artist', as: 'artist'
  get 'artists', to: 'users#artists', as: 'artists'
  
  get 'about', to: 'home#about'
  get 'birdfeed', to: 'home#birdfeed'

  resources :contacts, only: [:index, :create]
  resources :slider_images

  resources :announcements, only: [:show]
  resources :releases, only: [:show, :index]
  get "download_release/:id", to: "releases#download", as: "download_release"
  get "get_release_tracks/:id", to: "releases#get_tracks", as: "get_release_tracks"

  resources :tracks
  get 'get_tracks', to: 'tracks#get_tracks'
  get "download_track/:id", to: "tracks#download", as: "download_track"

  resources :topics
  resources :posts do
    get 'reply_form'
  end

  get "is_seen", to: "feeds#is_seen"

  resources :follows
  resources :comments
  resources :likes

  resources :chirp, controller: 'topic_categories', only: [:show, :index] do
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
