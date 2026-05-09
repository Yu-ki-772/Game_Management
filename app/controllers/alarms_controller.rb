class AlarmsController < ApplicationController
  include CalendarLoadable

  before_action :set_alarm, only: [ :edit, :update, :destroy ]

  def index
    @memberships = index_memberships
  end

  # カレンダー
  def calendar
    load_calendar_data
  end

  # 未ストップ（でかつストップ可能な）アラームの表示
  def pending
    @pending_memberships = current_user.pending_alarm_memberships
  end

  def new
    @alarm = current_user.alarms.build
    @start_date = params[:start_date]&.to_date
    now = Time.current.change(sec: 0)

    # アラームの設定時間のデフォルトは1時間後
    @alarm.scheduled_at = now + 1.hour

    # カレンダーから未来の日付が渡された場合は上書き
    if params[:date].present?
      selected_date = Date.parse(params[:date]) rescue nil

      if selected_date && selected_date > Date.today
        @alarm.scheduled_at = selected_date.to_time.change(hour: now.hour, min: now.min)
      end
    end

    # 作成画面に入ったときに、started_atの初期値をscheduled_atの1時間前にするために取得
    @alarm.started_at = @alarm.scheduled_at - 1.hour
  end

  def create
    @alarm = current_user.alarms.new(alarm_params)

    if @alarm.save
      check_pwa_install_prompt

      @membership = @alarm.alarm_memberships.find_by(user: current_user)
      @memberships = index_memberships
      @pending_memberships = current_user.pending_alarm_memberships

      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = "アラームを作成しました"
          if params[:start_date].present?
            load_calendar_data
            @update_calendar = true
          end
        end
        format.html { redirect_to alarms_path, notice: "アラームを作成しました", status: :see_other }
      end
    else
      flash.now[:alert] = "アラームを作成できませんでした"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @start_date = params[:start_date]&.to_date
  end

  def update
    if @alarm.update(alarm_params)
      @membership = @alarm.alarm_memberships.find_by(user: current_user)
      @memberships = index_memberships

      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = "アラームを更新しました"
          if params[:start_date].present?
            load_calendar_data
            @update_calendar = true
          end
        end
        format.html { redirect_to alarms_path, notice: "アラームを更新しました", status: :see_other }
      end
    else
      flash.now[:alert] = "アラームを更新できませんでした"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @alarm.destroy!
    redirect_to alarms_path, notice: "アラームを削除しました", status: :see_other
  end

  private

  def set_alarm
    @alarm = current_user.alarms.find(params[:id])
  end

  # ストロングパラメータ
  def alarm_params
    params.require(:alarm).permit(:label, :scheduled_at, :started_at, :reminder_minutes)
  end

  def index_memberships
    current_user.alarm_memberships
                .not_stopped_by(current_user)
                .joins(:alarm)
                .merge(Alarm.unsent.future.not_stopped)
                .includes(
                  alarm: [
                    { creator: { avatar_attachment: :blob } },
                    { members: { avatar_attachment: :blob } },
                    :alarm_memberships
                  ]
                )
                .order("alarms.scheduled_at asc")
  end

  # pwaインストール（ホーム画面に追加）を促すモーダルを表示済みかどうかの確認
  def check_pwa_install_prompt
    return if current_user.pwa_install_prompted
    
    flash[:show_pwa_install_prompt] = true
    current_user.update!(pwa_install_prompted: true)
  end
end