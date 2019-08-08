class Api::V1::QuestionsController < Api::V1::BaseController
  before_action :set_question, only: %i[show]
  authorize_resource

  def index
    @questions = Question.all
    render json: @questions
  end

  def show
    render json: @question, serializer: QuestionDetailedSerializer
  end

  private

  def set_question
    @question = Question.find(params[:id])
  end
end
