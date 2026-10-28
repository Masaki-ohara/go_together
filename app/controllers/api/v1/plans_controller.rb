module Api
    module V1
        class PlansController < ApplicationController
            before_action :authenticate_api_v1_user!
            # def create
            #      group = current_api_v1_user.groups.find(params[:group_id])
            #      if plan.save
            #         params[:lists].each do |content|
            #             next if content.blank?
            #             plan.plan_items.create(content: content)
            #         end
            #         render json: { message: 'プランが正常に作成されました' }, status: :created
            #      else
            #         render json: { errors: "プランの作成に失敗しました。" }, status: :unprocessable_entity
            #     end
            # end
            def create
                group = current_api_v1_user.groups.find(params[:group_id])
                plan = group.plans.build(plan_params)

                if plan.save
                  # ⭕️ params[:lists] から安全にデータを取り出すループ処理
                  params[:lists]&.each do |item|
                    if item.is_a?(String)
                      content_text = item
                      time_zone = nil
                    else
                      # ⭕️ React側が「text」で送ってくるのをRailsの「content」に変換して取得
                      content_text = item[:text] || item[:content]
                      time_zone = item[:time]
                    end

                    next if content_text.blank?

                    # ⭕️ 新しい time カラムと content カラムにそれぞれ直接保存！
                    plan.plan_items.create(content: content_text, time: time_zone)
                  end

                  render json: { message: "プランが正常に作成されました" }, status: :created
                else
                  Rails.logger.error("❌ プラン作成エラー: #{plan.errors.full_messages}")
                  render json: { errors: plan.errors.full_messages }, status: :unprocessable_entity
                end
            end

            # def index
            #     plans = Plan.all
            #     render json: plans, status: :ok
            # end
            # def index
            #     group = current_api_v1_user.groups.find(params[:group_id])
            #     plans = group.plans
            #     deadline = group.deadline
            #     render json: { plans: plans, deadline: deadline }, status: :ok
            # end
            def index
                group = current_api_v1_user.groups.find(params[:group_id])
                # 直近（最新）で確定したスケジュールを取得
                latest_schedule = group.schedules.order(created_at: :desc).first
                 if latest_schedule
                    # ⭕️ 最新スケジュール確定日より後に作られたプランだけを取得（1回目のプランを全除外）
                    plans = group.plans.where("created_at > ?", latest_schedule.created_at).order(created_at: :desc)
                 else
                    # まだ1回も確定していない場合は全プランを取得
                    plans = group.plans.order(created_at: :desc)
                 end

                deadline = group.deadline
                # ⭕️ schedules_count を含めてレスポンスを返す
                # render json: {
                #      plans: plans,
                #       deadline: deadline,
                #       schedules_count: group.schedules.count
                #       }, status: :ok
                # ⭕️ 投票データ（votes）や投票数も一緒にレスポンスに含めるようにする
                render json: {
                    plans: plans.as_json(include: { votes: { only: [ :id, :user_id ] }, plan_items: {} }),
                    deadline: deadline,
                    schedules_count: group.schedules.count
                }, status: :ok
            end

            def show
                plan = Plan.find(params[:id])
                render json: plan, include: :plan_items, status: :ok
            end

            def update
                plan = Plan.find(params[:id])
                if plan.update(plan_params)
                    render json: plan, include: :plan_items
                else
                    render json: { errors: plan.errors.full_messages }, status: :unprocessable_entity
                end
            end

            def destroy
              plan = Plan.find(params[:id])
                if plan.destroy
                    render json: { message: "プランが正常に削除されました" }, status: :ok
                else
                    render json: { errors: plan.errors.full_messages }, status: :unprocessable_entity
                end
            end

            private

            def plan_params
                params.require(:plan).permit(:date, :location, :budget, :title, :time, plan_items_attributes: [ :id, :content, :time, :_destroy ])
            end
        end
    end
end
