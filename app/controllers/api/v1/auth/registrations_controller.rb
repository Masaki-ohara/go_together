# class V1::Auth::RegistrationsController < DeviseTokenAuth::RegistrationsController

#     def sign_up_params
#       params.require(:registration).permit(:name, :email, :password, :password_confirmation, :image)
#     end
# end
class V1::Auth::RegistrationsController < DeviseTokenAuth::RegistrationsController

  def create
    super do |resource|
      if resource.persisted?
        render json: {
          status: "success",
          message: "ユーザー登録が完了しました"
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
