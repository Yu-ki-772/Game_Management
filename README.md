# Game Exit
### 「ゲーム時間が長引いてしまう」を解決する！

ゲーム仲間との共同プレイにも目を向けた「ゲーム時間管理アプリ」です。

<img width="600" src="https://github.com/user-attachments/assets/01fb9d6f-0dfa-4afe-bd04-503bae5b2dce" />

---

## アプリURL

https://game-exit.com/

**【ゲストユーザーアカウント情報】**

- ゲストユーザー1 / Email : guest@example.com / Password : password
- ゲストユーザー2 / Email : guest2@example.com / Password : password

---

## サービス開発の背景

自分自身、昔から大のゲーム好きでした。
しかし課題として、「ゲーム時間の管理」が難しいと感じていました。

ゲームは非常に楽しいもので、「あっという間に時間が過ぎている」、「いざやめようとしても、なかなかやめられない」という課題を感じている人も多いはずです。
また、ゲーム時間が延び過ぎることで、「睡眠不足」や「人間関係への影響」といった弊害も生じることがあります。

そこで、ゲーム時間を適切に管理することで、ゲームライフをより充実させたいと考え、本アプリを開発しました。

---

## 解決したい課題

- ゲーム時間が延びる「根本原因」を、複数の視点から探せること
- 共同プレイ中に、ゲーム仲間に「やめよう」と切り出しやすくなること

---

## 主な機能

### アラーム機能

<img src="https://github.com/user-attachments/assets/46d7a5d9-5333-4019-bc03-df6f77d8f458" width="600">

ゲームの開始時間と終了時間を設定し、終了時間になったら通知が届きます。なお、リマインダーの設定も可能です。

### フレンドとのアラーム共有機能

<img src="https://github.com/user-attachments/assets/e2c4ffb7-2e50-4ead-bd0e-cf975b291ba7" width="600">

フレンドをアラームに招待することでアラームを共有できます。

### プレイ時間の記録機能

<img src="https://github.com/user-attachments/assets/6e34834c-3a59-46d5-9558-ffed893dbe9f" width="600">

プレイ時間の記録を、グラフ等で複数の視点で確認できます。

### 定型文機能

<img src="https://github.com/user-attachments/assets/838a06fd-f0b8-47f7-a406-4e7ede2b2cca" width="600">

ゲーム仲間にやめるのを切り出しづらい場合に、事前に用意した定型文を即座にコピーし使用できます。

---

## 技術スタック

| カテゴリ | 技術 |
| --- | --- |
| バックエンド | Ruby on Rails |
| フロントエンド | Hotwire（Turbo / Stimulus） / Tailwind CSS v4 |
| データベース | PostgreSQL（Supabase） |
| 画像関連 | Cloudinary / Active Storage / libvips |
| バックグラウンドジョブ | Good Job |
| カレンダー | simple_calendar |
| 検索 | ransack |
| ページネーション | pagy |
| 通知 | Web Push API / Service Worker（PWA） |
| 環境構築 | Docker |
| 本番環境 | Render（Native Runtime） |
| 計測 | Google Analytics |

---

## 技術選定理由

**Supabase（PostgreSQL）**

Renderの無料PostgreSQLは30日で失効し、Neonは稼働時間に制限があるためバックグラウンドジョブのポーリングと相性が悪い。Aivenは稼働時間の制限がなくシンプルに使えるが、RenderのWebサーバーが置かれているシンガポールリージョンに対応していない。アプリとDBのリージョンを一致させてネットワーク遅延を抑えるため、シンガポールリージョンを持つSupabaseを採用。
→ [詳細記事](https://qiita.com/Shiro_yy/items/58f055639796f92d1d6f)

**Render**

fly.ioは無料プランが廃止済み、KoyebはリージョンがフランクフルトまたはワシントンDCに限られレイテンシが大きい。RenderはシンガポールリージョンとGitHub連携による自動デプロイを無料枠で利用できる。
→ [詳細記事](https://qiita.com/Shiro_yy/items/f90fd41ccabcd727ecfb)

**Good Job**

SidekiqはRedisが必要で導入コストが高い。Solid Queueは管理UIがなく別途gemが必要。Good JobはDBだけで動作し、ジョブの実行履歴・エラー・リトライ状況を確認できる管理画面が標準で組み込まれている。
→ [詳細記事](https://qiita.com/Shiro_yy/items/6bb5e147ddd7c15736ad)

**Cloudinary / Active Storage / libvips**

Active StorageはRails標準として安定してメンテナンスされているため採用。Cloudinaryは導入手順がシンプルで日本語の実装記事が豊富な点が決め手。libvipsはRails公式ドキュメントにもあるようにImageMagickと比べて高速かつメモリ効率が高い。
→ [詳細記事](https://qiita.com/Shiro_yy/items/141767ae5e5cc2dce033)

**simple_calendar**

Google Calendar APIは外部カレンダーとの連携が不要な今回の要件には過剰。FullCalendarはJavaScriptの関心事が増えオーバースペック。simple_calendarはERBテンプレートが標準で用意されており、Railsの文脈だけで完結できる。
→ [詳細記事](https://qiita.com/Shiro_yy/items/c1239e748f3844331cbb)

**ransack / pagy**

pg_searchやkaminariは更新が滞っている。また、pg_searchは今回の要件にはオーバースペック。ransackとpagyはともに積極的にメンテナンスされており、シンプルな要件に過不足なくフィットしている。
→ [詳細記事](https://qiita.com/Shiro_yy/items/157b5bde85354ffc20dc)

## ER図
[<img src="https://github.com/user-attachments/assets/c22b262a-18c6-454d-a3b9-fa9dc164e3aa" />](https://drive.google.com/file/d/1peliZu3S-7Y-Ucdi7gNU5Jug4bT9Q32d/view?usp=sharing)

テーブル構成は大きく分けて、**「ユーザー情報」** **「アラーム・記録」** **「定型文」** **「その他」**の4つに分類されます。

### ユーザー情報に関するテーブル
こちらでは、ユーザー名やメールアドレス、アイコン画像などの基本的な情報を `usersテーブル` で管理しています。また、ブラウザやデバイスごとのプッシュ通知の購読情報を `web_push_subscriptionsテーブル` で管理しており、`usersテーブル` と関連付けることで、ユーザーごとに複数デバイスへの通知を送れる設計にしています。

### アラーム・記録に関するテーブル
こちらでは、アラームの設定情報を管理する `alarmsテーブル` と `usersテーブル` を関連付けることで、ユーザーごとにアラームを作成・管理できるようにしました。

また、アラームへの参加状況や通知の送信状態を管理する `alarm_membershipsテーブル` を作成し、`alarmsテーブル` と関連付けています。これにより、フレンドと共有したアラームに対して、参加者ごとの通知状態を個別に管理できます。

さらに、アラームがストップされた際の記録を `alarm_logsテーブル` で管理しており、プレイ時間やストップまでの時間などの実績データをユーザごとに保存できる設計にしています。

### 定型文に関するテーブル
こちらでは、定型文を管理する `message_templatesテーブル`、定型文のブックマーク情報を保存する `bookmarksテーブル` を作成し、`usersテーブル` と関連付けています。

### その他のテーブル
まず、ユーザー間のフレンド関係を管理する `friendshipsテーブル` については、`statusカラム` を用いて申請中・承認済みの状態を管理できるようにしました。

そして、ゲーム時間管理度診断の結果を記録する `diagnosis_resultsテーブル` を `usersテーブル` と関連付けることで、ユーザーごとに診断履歴を管理できる設計にしています（※診断履歴の確認機能は今後実装する予定）。

## こだわった実装
### ダークモードのちらつき防止
ダークモードをJavaScriptファイルで実装すると、ページ読み込み時に
一瞬ライトモードで表示される**ちらつきが発生**します。

ブラウザはHTMLを上から順にパースするため、
ファイルとして読み込むスクリプトの実行はレンダリングより後になります。
そのためファイル側でテーマを切り替えても、最初の描画には間に合いません。

**インラインスクリプトをCSSより前に配置**することで、
最初のレンダリング時点で`.dark`クラスを確定させ、ちらつきをゼロにしています。

```html: app/views/layouts/application.html.erb
<%# CSSより前に配置 %>
<script>
  const saved = localStorage.getItem("theme");
  const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
  const isDark = saved === "dark" || (saved !== "light" && prefersDark);
  if (isDark) document.documentElement.classList.add("dark");
</script>
```
### 検索機能のプライバシー保護
<img width="600" src="https://github.com/user-attachments/assets/7f49f6ee-fba8-419b-ab9a-eebc3e87806d" />

ユーザー検索機能では、検索ワードがない状態で全ユーザーを表示してしまうと、
本名で登録しているユーザーの名前が意図せず一覧に表示されてしまうリスクがあります。

そのため、検索ワードがない場合は`User.none`を返すことで、
**データベースへの問い合わせ自体を発行せず、一覧に何も表示しない**設計にしています。

```ruby
base_scope = params.dig(:q, :name_cont).present? ? @q.result : User.none
```

これにより、ユーザーが明示的に検索ワードを入力した場合のみ
結果が表示される設計となっています。