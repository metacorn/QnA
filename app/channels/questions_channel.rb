class QuestionsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "questions"
  end

  def unsubscribed
  end
end
