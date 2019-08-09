Rails.application.routes.draw do
  use_doorkeeper

  namespace :api do
    namespace :v1 do
      resources :profiles, only: %i[index] do
        get :me, on: :collection
      end

      resources :questions, only: %i[index show create update destroy] do
        resources :answers, shallow: true, only: %i[index show create]
      end
    end
  end

  devise_for :users, controllers: { omniauth_callbacks: 'oauth_callbacks',
                                    confirmations: 'confirmations' }
  devise_scope :user do
    post "/confirm_email", to: "oauth_callbacks#confirm_email"
    get "/verify_email", to: "oauth_callbacks#verify_email"
  end

  root to: "questions#index"

  concern :votable do
    member do
      post :vote_up
      post :vote_down
      delete :cancel_vote
    end
  end

  concern :commentable do
    resources :comments, only: %i[create]
  end

  resources :questions, concerns: [:votable, :commentable] do
    resources :answers, concerns: [:votable, :commentable], shallow: true, except: %i[index show] do
      member do
        post :mark
      end
    end

    resources :files, shallow: true, only: %i[destroy]
  end

  resources :links, only: :destroy

  resources :users, only: %i[] do
    resources :badges, shallow: true, only: %i[index]
  end

  mount ActionCable.server, at: '/cable'
end
