set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:migrate

# RUN_SEEDSが設定されていない場合は、デフォルトでfalseにする。
RUN_SEEDS=${RUN_SEEDS:-false}

# seedsの実行（環境変数で実行の有無を切り替え可能）
if [ "$RUN_SEEDS" = "true" ]; then
  bundle exec rails db:seed
fi