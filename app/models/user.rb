# # frozen_string_literal: true

# class User < ActiveRecord::Base
#   # Include default devise modules. Others available are:
#   # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
#   has_one_attached :image
#   devise :database_authenticatable, :registerable,
#          :recoverable, :rememberable, :validatable
#   include DeviseTokenAuth::Concerns::User
# end
class User < ActiveRecord::Base
  has_one_attached :image

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  def serializable_hash(options = nil)
    super({
      only: [:id, :email, :name], # 必要な属性だけにする
    }.merge(options || {}))
  end
end
