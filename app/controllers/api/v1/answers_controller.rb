class Api::V1::AnswersController < Api::V1::BaseController
  before_action :set_question, only: %i[index]
  before_action :set_answer, only: %i[show]

  authorize_resource

  def index
    render json: @question.answers
  end

  def show
    render json: @answer, serializer: AnswerDetailedSerializer
  end

  private

  def set_answer
    @answer = Answer.find(params[:id])
  end

  def set_question
    @question = Question.find(params[:question_id])
  end
end
