Rails.application.routes.draw do
  resources :alarms, only: %i[index new create edit update destroy]
  resources :message_templates, only: [ :index ]
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "home#top"
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"

  # 開発環境でメール送信を確認（letter_opener_web）
  # URL: http://localhost:3000/letter_opener/
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?


  # バックグラウンドジョブのダッシュボード（good_job）
  # ※管理者ユーザのみアクセス可能
  # URL: http://localhost:3000/good_job/jobs?locale=ja
  authenticate :user, ->(user) { user.admin? } do
    mount GoodJob::Engine => "good_job"
  end
end
