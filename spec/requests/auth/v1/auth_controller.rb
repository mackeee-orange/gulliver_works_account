# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Auth::V1::AuthController, type: :request do
  describe 'POST /auth/v1/sign_in' do
    let(:request) { post auth_v1_sign_in_path, params: params }
    let(:account) { create(:account) }
    let!(:profile) { create(:profile, account: account) }

    let(:params) do
      { account: { email: account.email, password: account.password } }
    end

    it '正常にサインアップできること' do
      expect { request }.to change(Jti, :count).by(+1)
      expect(response).to have_http_status(:ok)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['account']['id']).to eq account.id
    end
  end

  describe 'POST /auth/v1/sign_up' do
    let(:request) { post auth_v1_sign_up_path, params: params }

    context '入力されたアドレスは未登録のもの' do
      let(:params) { { account: { email: 'sample@example.com', password: 'password' } } }

      it '正常にサインアップできること' do
        expect { request }.to change(Account, :count).by(+1)
        expect(response).to have_http_status(:created)
      end
    end

    context '入力されたアドレスは既に登録済みのもの' do
      let!(:account) { create(:account, email: 'sample@example.com') }
      let(:params) { { account: { email: 'sample@example.com', password: 'password' } } }

      it 'サインアップに失敗すること' do
        expect { request }.not_to change(Account, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
