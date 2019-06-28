require 'rails_helper'

RSpec.describe FilesController, type: :controller do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:question1) { create(:question, :with_attachments, user: user1) }
  let(:question2) { create(:question, :with_attachments, user: user2) }
  let(:answer1) { create(:answer, :with_attachments, question: question1, user: user2) }
  let(:answer2) { create(:answer, :with_attachments, question: question2, user: user1) }
  let!(:question_attachment1) { question1.files.first }
  let!(:question_attachment2) { question2.files.first }
  let!(:answer_attachment1) { answer1.files.first }
  let!(:answer_attachment2) { answer2.files.first }

  describe "DELETE #destroy" do
    context "authenticated user" do
      before { login(user1) }

      it "deletes users's question attachment" do
        expect {
          delete :destroy, params: { id: question_attachment1 }, format: :js
        }.to change(question1.files.attachments, :count).by(-1)
      end

      it "deletes users's answer attachment" do
        expect {
          delete :destroy, params: { id: answer_attachment2 }, format: :js
        }.to change(answer2.files.attachments, :count).by(-1)
      end

      it "tries to delete another user's question attachment" do
        expect {
          delete :destroy, params: { id: question_attachment2 }, format: :js
        }.to_not change(question2.files.attachments, :count)
      end

      it "tries to delete another user's answer attachment" do
        expect {
          delete :destroy, params: { id: answer_attachment1 }, format: :js
        }.to_not change(answer1.files.attachments, :count)
      end

      it "render destroy template after deleting of question attachment" do
        delete :destroy, params: { id: question_attachment1 }, format: :js

        expect(response).to render_template :destroy
      end

      it "render destroy template after deleting of answer attachment" do
        delete :destroy, params: { id: answer_attachment2 }, format: :js

        expect(response).to render_template :destroy
      end
    end

    it "unauthenticated user tries to delete question attachment" do
      expect {
        delete :destroy, params: { id: question_attachment1 }, format: :js
      }.to_not change(question1.files.attachments, :count)
    end

    it "unauthenticated user tries to delete answer attachment" do
      expect {
        delete :destroy, params: { id: answer_attachment1 }, format: :js
      }.to_not change(answer1.files.attachments, :count)
    end
  end
end
