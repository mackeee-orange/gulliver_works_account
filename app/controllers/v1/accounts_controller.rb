# frozen_string_literal: true

module V1
  # アカウントのリクエストハンドラ
  class AccountsController < ApplicationController
    load_and_authorize_resource

    def show
      render json: @account
    end

    def update
      # TODO: modelへ
      if resource_params[:email].present? && @account.email == resource_params[:email]
        @account.errors[:email] << '同じEmailがリクエストされています'
        fail ActiveRecord::RecordInvalid, @account
      end
      @account.update!(resource_params)
      AccountMailer.verification_new_email(@account.id, resource_params[:email]).deliver_later
      render json: @account
    end

    def destroy
      @account.destroy!
      head 204
    end

    private

    def resource_params
      params.require(:account).permit(:email)
    end
  end
end
