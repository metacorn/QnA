class Api::V1::AnswersController < Api::V1::BaseController
  before_action :set_question, only: %i[index create]
  before_action :set_answer, only: %i[show update destroy]

  authorize_resource

  def index
    render json: @question.answers
  end

  def show
    render json: @answer, serializer: AnswerDetailedSerializer
  end

  def create
    @answer = @question.answers.new(answer_params.merge(user: current_user))
    if @answer.save
      render json: @answer
    else
      render json: { messages: @answer.errors.full_messages }
    end
  end

  def update
    return head :forbidden unless current_user.owner?(@answer)
    @answer.update(answer_params)
    if @answer.save
      render json: @answer
    else
      render json: { messages: @answer.errors.full_messages }
    end
  end

  def destroy
    return head :forbidden unless current_user.owner?(@answer)
    @answer.destroy
    render json: { messages: ["Answer was successfully deleted."] }
  end

  private

  def set_answer
    @answer = Answer.find(params[:id])
  end

  def set_question
    @question = Question.find(params[:question_id])
  end

  def answer_params
    params.require(:answer).permit(:body)
  end
end
