require 'rails_helper'

RSpec.describe FilesController, type: :controller do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:question1) { create(:question, :with_attachments, user: user1) }
  let(:question2) { create(:question, :with_attachments, user: user2) }
  let!(:attachment1) { question1.files.first }
  let!(:attachment2) { question2.files.first }

  describe "DELETE #destroy" do
    context "authenticated user" do
      before { login(user1) }

      it "deletes users's question attachment" do
        expect {
          delete :destroy, params: { id: attachment1 }, format: :js
        }.to change(question1.files.attachments, :count).by(-1)
      end

      it "tries to delete another user's question attachment" do
        expect {
          delete :destroy, params: { id: attachment2 }, format: :js
        }.to_not change(question2.files.attachments, :count)
      end

      it "render destroy template" do
        delete :destroy, params: { id: attachment1 }, format: :js

        expect(response).to render_template :destroy
      end
    end

    it "unauthenticated user tries to delete question attachment" do
      expect {
        delete :destroy, params: { id: attachment1 }, format: :js
      }.to_not change(question1.files.attachments, :count)
    end
  end
end
