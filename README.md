# Game Exit
### 「ゲーム時間が長引いてしまう」を解決する！
ゲーム仲間との共同プレイにも目を向けた「ゲーム時間管理アプリ」です。

<img width="650" src="https://github.com/user-attachments/assets/01fb9d6f-0dfa-4afe-bd04-503bae5b2dce" />



### アプリURL

https://game-exit.com/

#### 【ゲストユーザーアカウント情報】

アカウントを作成せずに使ってみたい方は、こちらのアカウントをお使いください。
| ユーザー名 | メールアドレス  | パスワード  |
| :--- | :--- | :--- |
| **ゲストユーザー1** | guest@example.com | password |
| **ゲストユーザー2** | guest2@example.com | password |



## サービス開発の背景

私自身、昔から大のゲーム好きでした。

しかし課題として、 **「ゲーム時間の管理」** が難しいと私自身も感じていましたし、一緒にゲームをプレイしたことのある友人も同じような課題を抱えていました。<br>
実際、 **「あっという間に時間が過ぎている」** 、 **「いざやめようとしても、なかなかやめられない」** という課題を感じている人は多いはずです。
また、ゲーム時間が延び過ぎることで、「睡眠不足」や「人間関係への影響」といった弊害も生じることがあります。

そこで、ゲーム時間を適切に管理することで、ゲームライフをより充実させたいと考え、本アプリを開発しました。



## クリアしたい課題

### ① ゲーム時間が延びる「根本原因」を、複数の視点から探せること
### ② 共同プレイ中に、ゲーム仲間に「やめよう」と切り出しやすくなること



## 主な機能
アラーム・記録機能を主軸に、ゲーム時間管理を複数の方向から手助けできるように設計しました。



### アラーム機能
ゲームの開始時間と終了時間を設定し、終了時間になったらブラウザから通知が届きます。<br>
なお、リマインダーの設定も可能です。

<img width="650" src="https://github.com/user-attachments/assets/93ac2618-f217-41f0-aaaf-7c573f6211a2" />



### フレンドとのアラーム共有機能
フレンドをアラームに招待することでアラームを共有できます。<br>
アラームに招待されたフレンドにもブラウザからの通知が届きます。

<img src="https://github.com/user-attachments/assets/e2c4ffb7-2e50-4ead-bd0e-cf975b291ba7" width="650">



### プレイ時間の記録機能
プレイ時間の記録を、グラフ等により複数の視点で確認できます。

<img width="650" src="https://github.com/user-attachments/assets/9619c1b4-fb13-4ec1-bf9e-f552cf28e4b8" />



### 定型文機能
ゲーム仲間にやめるのを切り出しづらい場合に、事前に用意した定型文を即座にコピーし使用できます。

<img src="https://github.com/user-attachments/assets/838a06fd-f0b8-47f7-a406-4e7ede2b2cca" width="650">



### 診断機能
質問に答え、診断結果を確認することで、自分のゲームとの向き合い方を振り返ることができます。

<img width="650" src="https://github.com/user-attachments/assets/25e4d791-1b59-4447-8b2b-8908894a1fda" />



### PWAインストール
ブラウザからの通知が、ブラウザを閉じていても届くようにするために、PWA化を実装しました。

## 機能面での差別化ポイント
### 前提
クリアしたい課題の１つとして、 **『共同プレイ中に、ゲーム仲間に「やめよう」と切り出しやすくなること』** があります。
### この課題をクリアするための機能
- **「アラーム共有機能」** や **「定型文機能」** で、共同プレイ時にも決めた時間通りにやめやすくしました。
- プレイ時間の記録の統計画面に、 **「一緒にプレイしたフレンドごとの引き延ばし時間」** のグラフが表示されるようにし、 **誰とプレイしたときに時間が延びがちか** を確認できるようにしました。
## 技術スタック

| カテゴリ | 技術 |
| --- | --- |
| バックエンド | Ruby on Rails 8 |
| フロントエンド | Hotwire（Turbo / Stimulus） / Tailwind CSS 4 |
| データベース | PostgreSQL |
| バックグラウンドジョブのキューアダプタ | Good Job |
| ブラウザからのプッシュ通知 | Web Push（gem）、Push API |
| アラームカレンダー | Simple Calendar |
| 画像処理関連 |  Active Storage / libvips / Cloudinary |
| 検索 | Ransack |
| ページネーション | Pagy |
| 開発環境の構築 | Docker |
| PaaS | Render |
| 本番DB | Supabase |
| 計測 | Google Analytics |



## 技術選定理由

### バックエンドに Ruby on Rails を選んだ理由
MVC・ルーティング・DB設計など必要な要素が整理されており、「この処理はなぜここに書くのか」という設計判断を実装とセットで身につけられる点を評価した。技術の幅を広げるよりRailsで設計力・実装力を深めてユーザーに価値を届けることを優先した判断。

### フロントエンド
**Hotwire（Turbo / Stimulus）を選んだ理由**<br>
・ Reactは本アプリには複雑な状態管理等が不要なため過剰と判断。<br>
⭐ **Hotwire（Turbo / Stimulus）** はバニラJSよりHotwireのほうがRailsとの一貫性を保ちながら可読性高く書けること、またRails 8の標準スタックである点から長期的なメンテナンス面でも安心感があり選定した。

### データベースに PostgreSQL を選んだ理由
バックグラウンドジョブのキューアダプタにGood Job gemを採用しており、Good JobはPostgreSQLでのみ動作するため。

### バックグラウンドジョブのキューアダプタに Good Job を選んだ理由

・ SidekiqはRedis（インフラ）が追加で必要で導入コストが高い。<br>
・ Solid Queueは管理UIがなく別途gemが必要。<br>
⭐ **Good Job** はDBだけで動作し、ジョブの実行履歴・エラー・リトライ状況を確認できる管理画面が標準で組み込まれている。

→ 詳細記事（ https://qiita.com/Shiro_yy/items/6bb5e147ddd7c15736ad ）

### アラームカレンダーに SimpleCalendar を選んだ理由

・ Google Calendar APIは外部カレンダーとの連携が不要な今回の要件には過剰と判断。<br>
・ Full Calendarほどの高度なフロントエンド機能が今回の要件には不要。また、JavaScriptの関心事が増えてしまう。<br>
⭐ **Simple Calendar** はERBテンプレートが標準で用意されており、Railsの文脈だけで完結するため、今回の要件にフィット。

→ 詳細記事（ https://qiita.com/Shiro_yy/items/c1239e748f3844331cbb ）



### 画像処理関連に Cloudinary / Active Storage / libvips を選んだ理由

⭐ **Active Storage** はRails標準として安定してメンテナンスされている。<br>
⭐ **Cloudinary** は導入手順がシンプルで日本語の実装記事が豊富。<br>
⭐ **libvips** はImage Magickと比べて高速かつメモリ効率が高い。

→ 詳細記事（ https://qiita.com/Shiro_yy/items/141767ae5e5cc2dce033 ）


### PaaSに Render を選んだ理由

・ Fly.ioは無料プランが廃止済み<br>
・ Koyeb（無料プラン）はリージョンがフランクフルトまたはワシントンDCに限られレイテンシが大きい。<br>
⭐ **Render** はシンガポールリージョンがある。また、GitHub連携による自動デプロイ（CD）を無料枠で簡単に設定できる。

→ 詳細記事（ https://qiita.com/Shiro_yy/items/f90fd41ccabcd727ecfb ）

### 本番DBに Supabase を選んだ理由

・ Renderの無料プランは30日で失効する。<br>
・ Neon無料プランは稼働時間に制限があるためバックグラウンドジョブのポーリングと相性が悪い。<br>
・ Aiven無料プランは稼働時間の制限がなくシンプルに使えるが、シンガポールリージョンに対応していない。（Renderのリージョンがシンガポールであるため、Renderとの間の処理でレイテンシが発生してしまう。）<br>
⭐ **Supabase無料プラン** はAivenが満たしている要件を満たしているのに加え、シンガポールリージョンがある。

→ 詳細記事（ https://qiita.com/Shiro_yy/items/58f055639796f92d1d6f ）










## ER図
[<img src="https://github.com/user-attachments/assets/c22b262a-18c6-454d-a3b9-fa9dc164e3aa" />](https://drive.google.com/file/d/1peliZu3S-7Y-Ucdi7gNU5Jug4bT9Q32d/view?usp=sharing)

テーブル構成は大きく分けて、 **「ユーザー情報」、「アラーム・記録」、「定型文」、「その他」** の4つに分類されます。

### ユーザー情報に関するテーブル
- ユーザー名やメールアドレス、アイコン画像などの基本的な情報を `usersテーブル` で管理しています。

- プッシュ通知の購読情報を `web_push_subscriptionsテーブル` で管理しており、`usersテーブル` と関連付けることで、ユーザーごとに複数デバイスへの通知を送れる設計にしています。

### アラーム・記録に関するテーブル
- アラームの設定情報を管理する `alarmsテーブル` と `usersテーブル` を関連付けることで、ユーザーごとにアラームを作成・管理できるようにしています。

- アラームへの参加状況や通知の送信状態を管理する `alarm_membershipsテーブル` を作成し、`alarmsテーブル` 、`usersテーブル`と関連付けています。これにより、フレンドと共有したアラームに対して、参加者ごとの通知状態を個別に管理できます。

- アラームがストップされた際の記録を `alarm_logsテーブル` で管理しており、プレイ時間やストップまでの時間などの記録データをユーザごとに保存できる設計にしています。

### 定型文に関するテーブル
- 定型文を管理する `message_templatesテーブル`、定型文のブックマーク情報を保存する `bookmarksテーブル` を作成し、それぞれ`usersテーブル` と関連付けています。

### その他のテーブル
- ユーザー間のフレンド関係を管理する `friendshipsテーブル` については、`statusカラム` を用いて **「フレンド申請中」・「フレンド申請承認済み」** の状態を管理できるようにしました。

- ゲーム時間管理度診断の結果を記録する `diagnosis_resultsテーブル` を `usersテーブル` と関連付けることで、ユーザーごとに診断履歴を管理できる設計にしています（※診断履歴の確認機能は今後実装する予定）。

## こだわった実装
### 「通知設定」と「PWAインストール」の案内
これらの案内モーダルにより、ユーザーが「どういった流れで通知が届くんだろう？」と迷うことを防止しています。
#### <通知設定の案内モーダル>
初回ログイン時に通知設定の案内モーダルが表示されるようにしています。

<img width="650" src="https://github.com/user-attachments/assets/08007ee3-52d6-4c5a-b48f-aaa893f37003" />



#### <PWAインストールの案内モーダル>
また、アラーム初回作成時に、PWAインストールの案内モーダルが表示されるようにしています。

<img width="650" src="https://github.com/user-attachments/assets/8888f106-8980-47ad-aa47-83e942675820" />


---
### ダークモードのちらつき防止
#### <問題点>
「アプリを開いたときのダークモードへの切り替え」をJSファイル側で実装すると、ページ読み込み時に
一瞬ライトモードで表示される **ちらつきが発生** します。

ブラウザはHTMLを上から順に処理するため、JSファイルとして読み込むスクリプトの実行は画面の描画（レンダリング）処理より後になります。
#### <解決策>
**インラインスクリプトをCSSより前に配置** することで、最初の画面の描画より前にダークモードのクラス（`dark`）を確定させ、ちらつきをゼロにしています。
#### app/views/layouts/application.html.erb
```erb
<%# CSSより前に配置 %>
<script>
  const saved = localStorage.getItem("theme");
  const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
  const isDark = saved === "dark" || (saved !== "light" && prefersDark);
  if (isDark) document.documentElement.classList.add("dark");
</script>

<!-- 中略 -->

<%# CSS %>
<%= stylesheet_link_tag :app, "data-turbo-track": "reload" %>
<%# JS %>
<%= javascript_include_tag "application", "data-turbo-track": "reload", type: "module" %>
```
---
### ユーザー検索機能のプライバシー保護
<img width="650" src="https://github.com/user-attachments/assets/7f49f6ee-fba8-419b-ab9a-eebc3e87806d" />

#### <問題点>
ユーザー検索機能では、検索ワードがない状態で全ユーザーを表示してしまうと、 **本名で登録しているユーザーの名前が意図せず一覧画面に表示されてしまうリスク** があります。

#### <解決策>
パラメータに検索ワードがない場合は`User.none`を返すことで、 **データベースへの問い合わせ自体を発行せず、一覧画面に何も表示しない設計** にしています。
#### app/controllers/users_controller.rb
```ruby
base_scope = params.dig(:q, :name_cont).present? ? @q.result : User.none
```