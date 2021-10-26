# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Auth::V1::AuthController, type: :request do
  describe 'POST /auth/v1/sign_in' do
    let(:request) { post auth_v1_sign_in_path, params: params }
    let(:account) { create(:account) }

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

  describe 'GET /auth/v1/verify_email' do
    subject(:request) { get auth_v1_verify_email_path(token: account.email_verification_token) }
    let(:account) { create(:account, email_verification_token: SecureRandom.uuid) }

    it 'メールアドレスが認証されること' do
      request
      expect(account.reload.email_verification_status).to eq Account::EmailVerificationStatus::VERIFIED
    end

    it '正しくリダイレクトされること' do
      request
      expect(response).to have_http_status(:found)
      expect(response.headers['Location']).to eq auth_v1_completed_verify_email_url
    end
  end

  describe 'GET /auth/v1/verify_new_email' do
    subject(:request) do
      post auth_v1_verify_new_email_path(token: token, email: email), headers: headers
    end
    let(:email) { 'hoge@example.com' }
    let(:account) { create(:account, email_verification_token: SecureRandom.uuid) }
    let(:headers) { { Authorization: "Bearer #{account.jwt}" } }

    context 'トークンがある場合' do
      let(:token) { account.email_verification_token }

      it '新しいメールアドレスに更新されること' do
        request
        expect(account.reload.email).to eq 'hoge@example.com'
      end
    end

    context 'トークンがない場合' do
      let(:token) { nil }

      it '更新できない' do
        request
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
