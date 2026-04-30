class Group < ApplicationRecord
  # 招待トークンの生成（名前を被らないように変更）
  before_create :generate_share_token

  # 中間テーブル経由で複数のユーザーと紐付ける設定
  has_many :user_groups, dependent: :destroy
  has_many :users, through: :user_groups

  # 元々のリーダー（作成者）との紐付け（必要なら残す）
  belongs_to :user, optional: true
  
  has_many :plans, dependent: :destroy

  private

  def generate_share_token
    # self.share_token はデータベースのカラムを指します
    self.share_token = SecureRandom.hex(10)
  end
end