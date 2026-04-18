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