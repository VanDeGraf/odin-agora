Rails.application.routes.draw do
  devise_for :users
  get "/users/:id", to: "users#profile"
  get "/users/:id/friends", to: "users#friends"
end
