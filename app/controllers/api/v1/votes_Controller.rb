class Api::V1::VotesController < ApplicationController

    before_action :authenticate_api_v1_user!

    def create
        plan = Plan.find(params[:plan_id])
        group = plan.group
        vote = plan.votes.build(user: current_api_v1_user)

        if group.deadline.present? && Time.current > group.deadline
            render json: { errors: ['投票期間は終了しました'] }, status: :unprocessable_entity
        return
        end
        
        if vote.save
            render json: { message: '投票が正常に行われました' }, status: :created
        else
            render json: { errors: vote.errors.full_messages }, status: :unprocessable_entity
        end
    end

    def destroy
        plan = Plan.find(params[:plan_id])
        vote = plan.votes.find_by(user: current_api_v1_user)

        if vote
            vote.destroy
            render json: { message: '投票が正常に取り消されました' }, status: :ok
        else
            render json: { errors: '投票が見つかりませんでした' }, status: :not_found
        end
    end
end