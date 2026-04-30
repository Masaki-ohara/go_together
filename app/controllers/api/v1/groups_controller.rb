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

    def index
        groups = current_api_v1_user.groups
        render json: groups, status: :ok
    end

    def show
        group = current_api_v1_user.groups.find(params[:id])
        render json: group, include: :plans, status: :ok
    end

    def share_token
        group = current_api_v1_user.groups.find(params[:id])
        render json: group, include: :plans, status: :ok
    end


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