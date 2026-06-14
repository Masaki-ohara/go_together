class Api::V1::GroupsController < ApplicationController
    before_action :authenticate_api_v1_user!

    def create
        group = Group.new(group_params.merge(user_id: current_api_v1_user.id))
        # group = current_api_v1_user.groups.build(group_params)
        if group.save
            group.users << current_api_v1_user
            render json: { message: 'グループが正常に作成されました', group: group }, status: :created
        else
            logger.error group.errors.full_messages
            render json: { errors: "グループの作成に失敗しました。" }, status: :unprocessable_entity
        end
    end


# app/controllers/api/v1/groups_controller.rb

# def index
#   # 1. ログイン中のユーザーが所属しているグループ一覧を取得
#   groups = current_api_v1_user.groups

#   # 2. 各グループの中に含まれる「メンバー一覧」に画像URLを埋め込むデータ構造を作る
#   groups_data = groups.map do |group|
#     {
#       id: group.id,
#       name: group.name,
#       # 👇 各グループのメンバー（users）をループして画像URLを仕込む
#       users: group.users.map { |user|
#         {
#           id: user.id,
#           name: user.name,
#           image: user.image.attached? ? Rails.application.routes.url_helpers.rails_blob_path(user.image, only_path: true) : nil
#         }
#       },
#       plans: group.plans # 今まで通りplansも含める場合は残す（不要なら削ってOK）
#     }
#   end

#   # 3. 作成したデータをJSON形式でReactに返す
#   render json: groups_data, status: :ok
# end

    def index
        groups = current_api_v1_user.groups.includes(:users, :plans)
        render json: groups.as_json(include: [:users, :plans]), status: :ok
    end


def show
  # ログインユーザーが所属するグループから、URLのID（1など）に一致するものを探す
  group = current_api_v1_user.groups.find(params[:id])
  
  # 1. メンバー一覧（画像URLを埋め込む）
  users_with_images = group.users.map do |user|
    {
      id: user.id,
      name: user.name,
      image: user.image.attached? ? Rails.application.routes.url_helpers.rails_blob_path(user.image, only_path: true) : nil
    }
  end

  # 2. プラン一覧（ログイン後画面が絶対に必要としているデータ）
  plans_data = group.respond_to?(:plans) ? group.plans : []

  # 3. ログイン後画面（React）が壊れないように、元のグループ情報もすべて混ぜて返す
  render json: {
    id: group.id,
    name: group.name,
    created_at: group.created_at,
    updated_at: group.updated_at,
    users: users_with_images, # 画像付きメンバー
    plans: plans_data         # プラン一覧
  }, status: :ok
rescue => e
  logger.error "Groups Show Error: #{e.message}"
  render json: { error: e.message }, status: :internal_server_error
end
#     def show
#         group = current_api_v1_user.groups.find(params[:id])
    
#     # 💡 メンバー一覧をループして、一人ひとりのプロフィール画像URLを含めたデータを作成
#         users_with_images = group.users.map do |user|
#             {
#                 id: user.id,
#                 name: user.name,
#                 # ユーザーが画像を持っていればそのパスを取得、なければnil
#                 image: user.image.attached? ? Rails.application.routes.url_helpers.rails_blob_path(user.image, only_path: true) : nil
#              }
#             end

#     # 💡 plansは今まで通りそのまま含める
#     plans_data = group.plans

#     # React側（GroupDetail.tsx）が受け取れる形に合わせてJSONを返却
#     render json: {
#       id: group.id,
#       name: group.name,
#       users: users_with_images, # 👈 画像URLが混ざったメンバー一覧
#       plans: plans_data
#     }, status: :ok
# end
#     #     group = current_api_v1_user.groups.find(params[:id])
#     #     render json: group, include: [:users, :plans], status: :ok
#     # end

#     def share_token
#         group = current_api_v1_user.groups.find(params[:id])
#         render json: group, include: :plans, status: :ok
#     end


    # def join
    #     group = Group.find_by(share_token: params[:token])

    #     if group
    #         group.user = current_api_v1_user
    #         if group.save
    #             render json: { message: 'グループに参加しました' }, status: :ok
    #         else
    #             render json: { errors: "グループへの参加に失敗しました。" }, status: :unprocessable_entity
    #         end
    #     else
    #         render json: { errors: "無効なトークンです。" }, status: :not_found
    #     end
    # end     

    def join
  # 1. 送られてきたトークンに一致するグループを探す
  # ※モデル側で SecureRandom を使うようにしたので、カラム名 share_token を確認
  group = Group.find_by(share_token: params[:token])

  if group
    # 2. すでに参加済みでないかチェック
    if group.users.include?(current_api_v1_user)
      render json: { message: '既にグループに参加しています', group_name: group.name }, status: :ok
    else
      # 3. 中間テーブルにユーザーを追加（コンソールで成功したあの処理です！）
      group.users << current_api_v1_user
      render json: { message: 'グループに参加しました！', group_name: group.name }, status: :ok
    end
  else
    # トークンが間違っている場合
    render json: { errors: "無効な招待リンクです。" }, status: :not_found
  end
end

    private
    def group_params
        params.require(:group).permit(:name)
    end
end