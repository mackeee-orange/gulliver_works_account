# frozen_string_literal: true
Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  namespace :auth do
    namespace :v1 do
      post :sign_in, to: 'auth#sign_in'
      post :sign_up, to: 'auth#sign_up'
      get :verify_email, to: 'auth#verify_email'
      post :verify_new_email, to: 'auth#verify_new_email'
      get :completed_verify_email, to: 'auth#completed_verify_email'
      get :failed_verify_email, to: 'auth#failed_verify_email'
    end
  end

  # Default Api
  namespace :v1 do
    resources :accounts, only: %i[show update destroy]
  end

  namespace :enterprise_auth do
    namespace :v1 do
      post :sign_in, to: 'auth#sign_in'
      post :sign_up, to: 'auth#sign_up'
    end
  end
end
