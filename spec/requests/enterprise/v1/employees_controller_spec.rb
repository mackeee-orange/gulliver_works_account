# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Enterprise::V1::EmployeesController, type: :request do
  let!(:employee) { create(:employee) }
  let(:headers) { { Authorization: "Bearer #{employee.jwt}" } }

  describe 'GET /v1/employees/:id' do
    subject(:request) { get enterprise_v1_employee_path(employee.id), headers: headers }

    it '指定したアカウントが取得できること' do
      request
      expect(response).to have_http_status(:ok)
      response_json = JSON.parse(response.body)
      expect(response_json['id']).to eq employee.id
    end
  end

  describe 'PATCH /v1/employees/:id' do
    subject(:request) { patch enterprise_v1_employee_path(target_employee.id), params: params, headers: headers }
    context '自分のアカウントの場合' do
      let(:target_employee) { employee }

      context 'email更新' do
        context '入力されたアドレスは未登録のもの' do
          let(:params) { { employee: { email: 'hoge@example.com' } } }

          xit 'アドレス確認メールが送信されること'
        end

        context '入力されたアドレスは既に登録済みのもの' do
          let(:params) { { employee: { email: 'hoge@example.com' } } }
          let!(:employee) { create(:employee, email: 'hoge@example.com') }

          it '失敗すること' do
            request
            expect(response).to have_http_status(:unprocessable_entity)
          end
        end
      end
    end

    context '他人のアカウントの場合' do
      let(:target_employee) { create(:employee) }
      let(:params) { { employee: attributes_for(:employee, email: 'fuga@example.com') } }

      it 'アカウントを更新できないこと' do
        request
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'DELETE /v1/employees/:id' do
    subject(:request) { delete enterprise_v1_employee_path(target_employee.id), headers: headers }

    context '自分のアカウント' do
      let!(:target_employee) { employee }

      it '削除できること' do
        expect { request }.to change(Employee, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context '他人のアカウント' do
      let!(:target_employee) { create(:employee) }

      it '削除できないこと' do
        expect { request }.not_to change(Employee, :count)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
