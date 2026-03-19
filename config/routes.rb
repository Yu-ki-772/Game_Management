Rails.application.routes.draw do
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest"       => "rails/pwa#manifest",       as: :pwa_manifest

  root "home#top"

  #==============================================================
  # ユーザ関連
  #==============================================================
  devise_for :users, controllers: { registrations: "users/registrations",
                                    omniauth_callbacks: "users/omniauth_callbacks",
                                    passwords: "users/passwords" }

  resources :users, only: %i[index show]

  #=============================================================
  # メインリソース
  #=============================================================
  resources :friendships, only: [ :index, :create, :update, :destroy ] do
    collection do
      get :pending
    end
  end

  resources :alarms, only: %i[index new create edit update destroy] do
    collection do
      get :pending
      get :calendar
    end
    member do
      patch :unlock
    end
    resources :alarm_memberships, only: [ :create, :destroy, :show ] do
      collection do
        # アラームに招待するユーザーを検索する用
        get :search_users
      end
      member do
        patch :unlock
      end
    end
  end
  resources :alarm_logs, only: %i[ index ] do
    collection do
      get :list # 記録一覧
    end
  end

  resources :message_templates, only: [ :index, :new, :create, :edit, :update, :destroy ] do
    collection do
      get :bookmarks
      get :manage
    end
  end


  # ゲーム時間管理度診断用
  resources :diagnosis_results, only: %i[ new create show ]


  #=============================================================
  # 補助リソース
  #=============================================================
  resources :bookmarks, only: %i[create destroy] # message_templatesのブックマーク機能用

  resource :notification_setting, only: %i[show]

  # プッシュ通知の購読管理
  resources :web_push_subscriptions, only: %i[create] do
    collection do
      delete :destroy # endpoint を受け取って削除する用のエンドポイント
    end
  end

  # バグ報告
  resource :bug_report, only: [ :new, :create ]

  # 静的ページ
  get "/privacy_policy" => "pages#privacy_policy", as: :privacy_policy # プライバシーポリシー
  get "/terms" => "pages#terms", as: :terms # 利用規約
  get "/others" => "pages#others", as: :others
  get "/guide" => "pages#guide", as: :guide

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
