# frozen_string_literal: true
module Auth
  module V1
    # AuthController
    class AuthController < ApplicationController
      skip_before_action :authenticate_account!

      def sign_in
        account = Account.find_by(
          email: resource_params[:email]
        ).try(:authenticate, resource_params[:password])

        account ? render(json: account, serializer: AccountWithTokenSerializer) : head(401)
      end

      def sign_up
        account = Account.create!(resource_params)
        AccountMailer.verification_email(@account.id).deliver_later
        render json: account, status: :created, serializer: AccountWithTokenSerializer
      end

      # アドレス確認（新規登録時）GETリクエスト
      def verify_email
        account = Account.find_by(email_verification_token: params[:token])
        return head 403 if params[:token].blank? || account.blank?

        if account.update(
          email_verification_status: Account::EmailVerificationStatus::VERIFIED,
          email_verification_token: nil
        )
          redirect_to completed_verify_email_url
        else
          redirect_to failed_verify_email_url
        end
      end

      # アドレス確認（アドレス変更時）
      def verify_new_email
        account = Account.find_by(email_verification_token: params[:token])
        fail ActiveRecord::RecordNotFound if params[:token].blank? || account.blank?

        authorize! :manage, account
        account.update!(email: params[:email], email_verification_token: nil)
        head 204
      end

      def completed_verify_email
        render html: 'メールアドレスの認証に成功しました'
      end

      def failed_verify_email
        render html: 'メールアドレスの認証に失敗しました'
      end

      private

      def resource_params
        params.require(:account).permit(:email, :password)
      end
    end
  end
end
