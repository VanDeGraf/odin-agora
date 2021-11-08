Rails.application.routes.draw do
  root to: "static_pages#feed"

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  get "/users/:id", to: "users#profile", as: "user"
  get "/users/:id/friends", to: "users#friends", as: "friends"

  get "/users/:id/delete_friend", to: "users#delete_friend", as: "delete_friend"
  get "/users/:id/cancel_friend_invite", to: "users#cancel_friend_invite", as: "cancel_friend_invite"
  get "/users/:id/invite_friend", to: "users#invite_friend", as: "invite_friend"
  get "/users/:id/accept_friend_request", to: "users#accept_friend_request", as: "accept_friend_request"
  get "/users/:id/decline_friend_request", to: "users#decline_friend_request", as: "decline_friend_request"

  get "/people", to: "static_pages#people"
  get "/feed", to: "static_pages#feed"
  get "/about", to: "static_pages#about"

  resources :posts, only: [:new, :create, :show]
  post "/posts/:id/create_comment", to: "posts#create_comment", as: "create_comment"

  get "/dialogs/", to: "dialogs#index"
  get "/dialogs/:id", to: "dialogs#show", as: "dialog"
  post "/dialogs/:id/create_message", to: "dialogs#create_message", as: "create_message"
end
