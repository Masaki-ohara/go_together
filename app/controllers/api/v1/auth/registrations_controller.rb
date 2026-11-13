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

        # プロフィール更新（マイページからのPUT/PATCH）
        def update
          super do |resource|
            if resource.persisted?
              image_url = resource.image.attached? ? Rails.application.routes.url_helpers.rails_blob_url(resource.image, only_path: true) : nil
              render json: {
                status: "success",
                message: "プロフィールを更新しました",
                data: {
                  id: resource.id,
                  name: resource.name,
                  email: resource.email,
                  image: image_url
                }
              }, status: :ok and return
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