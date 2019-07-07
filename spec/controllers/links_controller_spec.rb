require 'rails_helper'

RSpec.describe LinksController, type: :controller do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:question1) { create(:question, user: user1) }
  let(:question2) { create(:question, user: user2) }
  let(:answer1) { create(:answer, question: question2, user: user1) }
  let(:answer2) { create(:answer, question: question1, user: user2) }
  let!(:question_link1) { create(:link, :valid, linkable: question1) }
  let!(:question_link2) { create(:link, :valid_gist, linkable: question2) }
  let!(:answer_link1) { create(:link, :valid, linkable: answer1) }
  let!(:answer_link2) { create(:link, :valid, linkable: answer2) }

  describe "DELETE #destroy" do
    context "authenticated user" do
      before { login(user1) }

      it "deletes user's question link" do
        expect {
          delete :destroy, params: { id: question_link1 }, format: :js
        }.to change(question1.links, :count).by(-1)
        expect { question_link1.reload }.to raise_error ActiveRecord::RecordNotFound
      end

      it "deletes user's answer link" do
        expect {
          delete :destroy, params: { id: answer_link1 }, format: :js
        }.to change(answer1.links, :count).by(-1)
        expect { answer_link1.reload }.to raise_error ActiveRecord::RecordNotFound
      end

      it "tries to delete another user's question link" do
        expect {
          delete :destroy, params: { id: question_link2 }, format: :js
        }.to_not change(question2.links, :count)
      end

      it "tries to delete another user's answer link" do
        expect {
          delete :destroy, params: { id: answer_link2 }, format: :js
        }.to_not change(answer2.links, :count)
      end

      it "render destroy template after deleting of question link" do
        delete :destroy, params: { id: question_link1 }, format: :js

        expect(response).to render_template :destroy
      end

      it "render destroy template after deleting of answer link" do
        delete :destroy, params: { id: answer_link1 }, format: :js

        expect(response).to render_template :destroy
      end
    end

    it "unauthenticated user tries to delete question link" do
      expect {
        delete :destroy, params: { id: question_link1 }, format: :js
      }.to_not change(question1.links, :count)
    end

    it "unauthenticated user tries to delete answer link" do
      expect {
        delete :destroy, params: { id: answer_link1 }, format: :js
      }.to_not change(answer1.links, :count)
    end
  end
end
