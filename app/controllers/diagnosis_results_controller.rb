# app/controllers/diagnosis_results_controller.rb

class DiagnosisResultsController < ApplicationController
  before_action :authenticate_user!

  def new
  end

  def create
    @result = DiagnosisResult.build_from_answers(current_user, params[:answers])

    if @result.save
      redirect_to @result, notice: "診断が完了しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @result = current_user.diagnosis_results.find(params[:id])
  end
end