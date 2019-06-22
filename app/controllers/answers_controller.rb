class AnswersController < ApplicationController
  before_action :authenticate_user!

  def new
    @answer = Answer.new
  end

  def create
    @question = Question.find(params[:question_id])
    @answer = @question.answers.new(answer_params)
    @answer.user = current_user
    @answer.save
  end

  def destroy
    answer = Answer.find(params[:id])
    return head :forbidden unless current_user.owned?(answer)
    answer.destroy
    redirect_to answer.question, notice: "Your answer was successfully deleted!"
  end

  private

  def answer_params
    params.require(:answer).permit(:body)
  end
end
