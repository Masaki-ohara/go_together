class User < ActiveRecord::Base
  has_one_attached :image
  has_many :user_groups, dependent: :destroy
  has_many :groups, through: :user_groups
  has_many :owned_groups, class_name: "Group", foreign_key: "user_id"
  has_many :votes, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :schedules, through: :tasks

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  def serializable_hash(options = nil)
    super({
      only: [ :id, :email, :name ]
    }.merge(options || {}))
  end

  #   def token_validation_response
  #   as_json(except: [:tokens, :created_at, :updated_at]).merge(
  #     image: image.attached? ? Rails.application.routes.url_helpers.url_for(image) : nil
  #   )
  # end
  def token_validation_response
    image_url = if image.attached?
      Rails.application.routes.url_helpers.rails_blob_url(
        image,
        host: "go-together-2kx6.onrender.com",
        protocol: "https"
      )
    end

    as_json(except: [:tokens, :created_at, :updated_at]).merge(
      image: image_url
    )
  end
end
