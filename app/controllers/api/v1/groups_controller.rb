class Api::V1::GroupsController < ApplicationController
    before_action :authenticate_api_v1_user!

    def create
        group = current_api_v1_user.groups.build(group_params)
        if group.save
            render json: { message: 'グループが正常に作成されました' }, status: :created
        else
            render json: { errors: "グループの作成に失敗しました。" }, status: :unprocessable_entity
        end
    end

    def index
        groups = current_api_v1_user.groups
        render json: groups, status: :ok
    end

    def show
        group = current_api_v1_user..groups.find(params[:id])
        render json: group, include: :plans, status: :ok
    end

    def share_token
        group = current_api_v1_user.groups.find(params[:id])
        render json: group, include: :plans, status: :ok
    end

    private
    def group_params
        params.require(:group).permit(:name)
    end
end