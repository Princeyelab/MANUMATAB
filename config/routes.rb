Rails.application.routes.draw do
  get "messages/create"
  devise_for :users
  root to: "pages#home"

  resources :interviews, only: [:index, :show, :new, :create] do
    resources :chats, only: [:show, :new, :create]
  end
end
