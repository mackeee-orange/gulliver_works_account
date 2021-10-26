# frozen_string_literal: true

module Enterprise
  module V1
    # Employeeのリクエストハンドラ
    class EmployeesController < EnterpriseController
      load_and_authorize_resource

      def show
        render json: @employee
      end

      def update
        # TODO: modelへ
        if resource_params[:email].present? && @employee.email == resource_params[:email]
          @employee.errors[:email] << '同じEmailがリクエストされています'
          fail ActiveRecord::RecordInvalid, @employee
        end
        @employee.update!(resource_params)
        AccountMailer.verification_new_email(@employee.id, resource_params[:email]).deliver_later
        render json: @employee
      end

      def destroy
        @employee.destroy!
        head 204
      end

      private

      def resource_params
        params.require(:employee).permit(:email)
      end
    end
  end
end