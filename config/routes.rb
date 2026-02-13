Rails.application.routes.draw do
  #=============================================================
  # メインリソース
  #=============================================================
  root "home#top"

  resources :alarms, only: %i[index new create edit update destroy] do
    collection do
      get :pending
    end
    member do
      patch :unlock
    end
  end
  resources :alarm_logs, only: %i[ index ]

  resources :message_templates, only: [ :index, :new, :create, :edit, :update, :destroy ] do
    collection do
      get :bookmarks
    end
  end
  #=============================================================
  # 補助リソース
  #=============================================================
  resources :bookmarks, only: %i[create destroy] # message_templatesのブックマーク機能用

  #==============================================================
  # ログイン認証
  #==============================================================
  devise_for :users, controllers: { registrations: "users/registrations",
                                    omniauth_callbacks: "users/omniauth_callbacks",
                                    passwords: 'users/passwords' }

  #==============================================================
  # その他
  #==============================================================
  get "up" => "rails/health#show", as: :rails_health_check


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
