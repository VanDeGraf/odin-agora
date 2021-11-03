Rails.application.routes.draw do
  root to: "static_pages#feed"

  devise_for :users
  get "/users/:id", to: "users#profile"
  get "/users/:id/friends", to: "users#friends"

  get "/people", to: "static_pages#people"
  get "/feed", to: "static_pages#feed"
  get "/about", to: "static_pages#about"
end
