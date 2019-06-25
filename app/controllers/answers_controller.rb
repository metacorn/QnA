class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_answer, only: %i[update destroy mark]

  def new
    @answer = Answer.new
  end

  def create
    @question = Question.find(params[:question_id])
    @answer = @question.answers.new(answer_params)
    @answer.user = current_user
    @answer.save
  end

  def update
    return head :forbidden unless current_user.owned?(@answer)
    @answer.update(answer_params)
    @question = @answer.question
  end

  def destroy
    return head :forbidden unless current_user.owned?(@answer)
    @answer.destroy
  end

  def mark
    return head :forbidden unless current_user.owned?(@answer.question)
    @answer.mark_as_best
    @question = @answer.question
  end

  private

  def answer_params
    params.require(:answer).permit(:body)
  end

  def set_answer
    @answer = Answer.find(params[:id])
  end
end
