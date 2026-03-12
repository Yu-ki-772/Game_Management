# app/controllers/bug_reports_controller.rb
class BugReportsController < ApplicationController

  def new
  end

  def create
    body = params[:body]

    if body.blank?
      flash[:alert] = '内容を入力してください'
      render :new, status: :unprocessable_entity
      return
    end

    if body.length > 1000
      flash[:alert] = '1000文字以内で入力してください'
      render :new, status: :unprocessable_entity
      return
    end

    BugReportMailer.report(body).deliver_later
    redirect_to others_path, notice: '不具合報告を送信しました。ありがとうございます。'
  end
end