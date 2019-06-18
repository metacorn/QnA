class AnswersController < ApplicationController
  before_action :authenticate_user!

  def new
    @answer = Answer.new
  end

  def create
    @question = Question.find(params[:question_id])
    @answer = @question.answers.new(answer_params)

    if @answer.save
      redirect_to @question, notice: "Your answer was saved."
    else
      redirect_to @question, alert: "Your answer was not saved."
    end
  end

  private

  def answer_params
    params.require(:answer).permit(:body)
  end
end
