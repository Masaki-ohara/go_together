class User < ActiveRecord::Base
  has_one_attached :image
  has_many :user_groups, dependent: :destroy
  has_many :groups, through: :user_groups
  has_many :owned_groups, class_name: 'Group', foreign_key: 'user_id'

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  def serializable_hash(options = nil)
    super({
      only: [:id, :email, :name],
    }.merge(options || {}))
  end
end
