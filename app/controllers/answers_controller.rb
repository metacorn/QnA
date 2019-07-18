class AnswersController < ApplicationController
  include Voted

  before_action :authenticate_user!
  before_action :set_answer, only: %i[update destroy mark]
  after_action :publish_answer, only: %i[create]

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
    return head :forbidden unless current_user.owner?(@answer)
    @answer.update(answer_params)
    @question = @answer.question
  end

  def destroy
    return head :forbidden unless current_user.owner?(@answer)
    @answer.destroy
  end

  def mark
    return head :forbidden unless current_user.owner?(@answer.question)
    @answer.mark_as_best
    @question = @answer.question
  end

  private

  def answer_params
    params.require(:answer).permit( :body,
                                    files: [],
                                    links_attributes: [:name, :url])
  end

  def set_answer
    @answer = Answer.find(params[:id])
  end

  def publish_answer
    return if @answer.errors.any?
    AnswersChannel.broadcast_to(@answer.question,
                                answer: @answer,
                                files: helpers.files_list(@answer.files),
                                links: helpers.links_list(@answer.links))
  end
end
