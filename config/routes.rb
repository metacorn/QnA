Rails.application.routes.draw do
  devise_for :users
  root to: "questions#index"

  resources :questions do
    resources :answers, shallow: true, except: %i[index show] do
      member do
        post :mark
      end
    end

    resources :files, shallow: true, only: %i[destroy]
  end

  resources :links, only: :destroy
end
