class Api::V1::QuestionsController < Api::V1::BaseController
  before_action :set_question, only: %i[show update destroy]
  authorize_resource

  def index
    @questions = Question.all
    render json: @questions
  end

  def show
    render json: @question, serializer: QuestionDetailedSerializer
  end

  def create
    @question = current_user.questions.new(question_params)
    if @question.save
      render json: @question
    else
      render json: { messages: @question.errors.full_messages }
    end
  end

  def update
    return head :forbidden unless current_user.owner?(@question)
    if @question.update(question_params)
      render json: @question
    else
      render json: { messages: @question.errors.full_messages }
    end
  end

  def destroy
    return head :forbidden unless current_user.owner?(@question)
    @question.destroy
    render json: { messages: ["Question was successfully deleted."] }
  end

  private

  def set_question
    @question = Question.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:title, :body)
  end
end
