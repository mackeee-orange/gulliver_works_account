module V1
  class AccountsController < ApplicationController
    load_and_authorize_resource

    def show
      render json: @account
    end

    def update
      @account.update!(resource_params)
      if resource_params[:email].present?
        fail Errors::InvalidEmailError if Account.pluck(:email).include?(resource_params[:email])

        AccountMailer.verification_new_email(@account.id, resource_params[:email]).deliver_later
      end
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