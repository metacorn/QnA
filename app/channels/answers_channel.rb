class AnswersChannel < ApplicationCable::Channel
  def subscribed
    question = Question.find(params[:id])
    stream_for question
  end

  def unsubscribed
  end
end
