# # class Api::V1::VotesController < ApplicationController

# #     before_action :authenticate_api_v1_user!

# #     def create
# #         plan = Plan.find(params[:plan_id])
# #         group = plan.group
# #         vote = plan.votes.build(user: current_api_v1_user)

# #         if group.deadline.present? && Time.current > group.deadline
# #             render json: { errors: ['投票期間は終了しました'] }, status: :unprocessable_entity
# #         return
# #         end

# #         if vote.save
# #             render json: { message: '投票が正常に行われました' }, status: :created
# #         else
# #             render json: { errors: vote.errors.full_messages }, status: :unprocessable_entity
# #         end
# #     end

# #     def destroy
# #         plan = Plan.find(params[:plan_id])
# #         vote = plan.votes.find_by(user: current_api_v1_user)

# #         if vote
# #             vote.destroy
# #             render json: { message: '投票が正常に取り消されました' }, status: :ok
# #         else
# #             render json: { errors: '投票が見つかりませんでした' }, status: :not_found
# #         end
# #     end

# #     def result
# #         plan = Plan.find(params[:plan_id])
# #         votes_count = plan.votes.count

# #         if plan.group.deadline.present? && Time.current <= plan.group.deadline
# #             render json: { errors: ['投票期間はまだ終了していません'] }, status: :unprocessable_entity
# #             return
# #         end
# #         render json: { votes_count: votes_count }, status: :ok
# #     end
# # end
# class Api::V1::VotesController < ApplicationController
#   before_action :authenticate_api_v1_user!

#   def create
#     plan = Plan.find(params[:plan_id])
#     group = plan.group
#     vote = plan.votes.build(user: current_api_v1_user)

#     if group.deadline.present? && Time.current > group.deadline
#       render json: { errors: ['投票期間は終了しました'] }, status: :unprocessable_entity
#       return
#     end

#     if vote.save
#       # ⭕ 最新の votes_count と voted フラグを返す
#       render json: {
#         message: '投票が正常に行われました',
#         vote_count: plan.vote.count,
#         voted: true
#       }, status: :created
#     else
#       render json: { errors: vote.errors.full_messages }, status: :unprocessable_entity
#     end
#   end

#   def destroy
#     plan = Plan.find(params[:plan_id])
#     vote = plan.vote.find_by(user: current_api_v1_user)

#     if vote
#       vote.destroy
#       # ⭕ 取消後も最新の votes_count と voted フラグを返す
#       render json: {
#         message: '投票が正常に取り消されました',
#         vote_count: plan.vote.count,
#         voted: false
#       }, status: :ok
#     else
#       render json: { errors: ['投票が見つかりませんでした'] }, status: :not_found
#     end
#   end

#   def result
#     plan = Plan.find(params[:plan_id])
#     # 💡 リアルタイムで投票数を画面に出したい場合は、ここでの deadline チェックを外します
#     render json: { vote_count: plan.votes.count }, status: :ok
#   end
# end
class Api::V1::VotesController < ApplicationController
  before_action :authenticate_api_v1_user!

  def create
    plan = Plan.find(params[:plan_id])
    group = plan.group
    vote = plan.votes.create(user: current_api_v1_user)

    if group.deadline.present? && Time.current > group.deadline
      render json: { errors: [ "投票期間は終了しました" ] }, status: :unprocessable_entity
      return
    end

    if vote.save
      # 💡 修正: plan.vote.count -> plan.votes.count (複数形に修正)
      render json: {
        message: "投票が正常に行われました",
        vote_count: plan.votes.count,
        voted: true
      }, status: :created
    else
      render json: { errors: vote.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    plan = Plan.find(params[:plan_id])
    # 💡 修正: plan.vote.find_by -> plan.votes.find_by (複数形に修正)
    vote = plan.votes.find_by(user: current_api_v1_user)

    if vote
      vote.destroy
      # 💡 修正: plan.vote.count -> plan.votes.count (複数形に修正)
      render json: {
        message: "投票が正常に取り消されました",
        vote_count: plan.votes.count,
        voted: false
      }, status: :ok
    else
      render json: { errors: [ "投票が見つかりませんでした" ] }, status: :not_found
    end
  end

  def result
    plan = Plan.find(params[:plan_id])
    render json: { vote_count: plan.votes.count }, status: :ok
  end
end
