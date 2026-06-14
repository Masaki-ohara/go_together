# class V1::Auth::RegistrationsController < DeviseTokenAuth::RegistrationsController

#     def sign_up_params
#       params.require(:registration).permit(:name, :email, :password, :password_confirmation, :image)
#     end
# end
module Api
  module V1
    module Auth
      class RegistrationsController < DeviseTokenAuth::RegistrationsController

        def create
          super do |resource|
            if resource.persisted?
              image_url = resource.image.attached? ? Rails.application.routes.url_helpers.rails_blob_url(resource.image, only_path: true) : nil
              render json: {
                status: "success",
                message: "ユーザー登録が完了しました",
                # 👇 render json: { } の中に data を入れます
                data: {
                  id: resource.id,
                  name: resource.name,
                  email: resource.email,
                  image: image_url
                }
              }, status: :created and return
            end
          end
        end

        private

        def sign_up_params
          params.permit(:name, :email, :password, :password_confirmation, :image)
        end

        def account_update_params
          params.permit(:name, :email, :password, :password_confirmation, :image)
        end

      end
    end
  end
end