class QuestionsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "questions"
  end

  def unsubscribed
    stop_all_streams
  end
end
