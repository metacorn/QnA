class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_question, only: %i[show edit update destroy]

  def index
    @questions = Question.all
  end

  def show
    @answer = Answer.new
  end

  def new
    @question = Question.new
  end

  def edit
  end

  def create
    @question = Question.new(question_params)
    @question.user = current_user

    if @question.save
      redirect_to @question, notice: "Your question was successfully created."
    else
      render :new
    end
  end

  def update
    return head :forbidden unless current_user.owner?(@question)
    @question.update(question_params)
  end

  def destroy
    return head :forbidden unless current_user.owner?(@question)
    @question.destroy
    redirect_to questions_path, notice: "Your question was successfully deleted!"
  end

  private

  def set_question
    @question = Question.with_attached_files.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:title, :body, files: [])
  end
end
