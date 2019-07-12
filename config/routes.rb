Rails.application.routes.draw do
  devise_for :users
  root to: "questions#index"

  concern :votable do
    member do
      post :vote_up
      post :vote_down
    end
  end

  resources :questions, concerns: [:votable] do
    resources :answers, concerns: [:votable], shallow: true, except: %i[index show] do
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
end
