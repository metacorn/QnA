class AnswersController < ApplicationController
  before_action :authenticate_user!

  def new
    @answer = Answer.new
  end

  def create
    @question = Question.find(params[:question_id])
    @answer = @question.answers.new(answer_params)
    @answer.user = current_user

    if @answer.save
      redirect_to @question, notice: "Your answer was saved."
    else
      redirect_to @question, alert: "Your answer was not saved."
    end
  end

  def destroy
    @answer = Answer.find(params[:id])
    @question = @answer.question
    if @answer.user == current_user
      @answer.destroy
      redirect_to @question, notice: "Your answer was successfully deleted!"
    end
  end

  private

  def answer_params
    params.require(:answer).permit(:body)
  end
end
