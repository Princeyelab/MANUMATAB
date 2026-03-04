Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"

  resources :interviews, only: [:index, :show] do
    resources :chats, only: [:create]
  end

  resources :chats, only: [:show] do
    resources :messages, only: [:create]
  end
end
