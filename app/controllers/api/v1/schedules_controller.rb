# class Api::V1::ScheduleController < ApplicationController
#     before_action :authenticate_api_v1_user!

#     def create
#         group = current_api_v1_user.groups.find(params[:group_id])
#         plan = group.plans.find(params[:plan_id])
#         # ここでスケジュールを確定する処理を実装
#         # 例えば、planのstatusを"confirmed"に変更するなど
#         plan.update(status: "confirmed")
#         render json: { message: "スケジュールが正常に確定されました", plan: plan }, status: :ok
#     end
module Api
  module V1
    class SchedulesController < ApplicationController
      before_action :authenticate_api_v1_user!
      
      # ⭕️ 1. スケジュールを新規作成・上書き保存する
      def create
        group = current_api_v1_user.groups.find(params[:group_id])

        # 👈 1. グループの作成者（group.user_id）か判定するチェックを追加
        if group.user_id != current_api_v1_user.id
          return render json: { error: "スケジュールの作成権限がありません" }, status: :forbidden
        end

        latest_schedule_time = group.schedules.maximum(:created_at)
        target_plans = if latest_schedule_time
           group.plans.where("created_at > ?", latest_schedule_time)
          else
            group.plans
          end
          
          if target_plans.empty?
            return render json: { error: "対象となるプランがありません" }, status: :unprocessable_entity
          end

        # すでにグループにスケジュールがあれば上書き、無ければ新しく作る
        # schedule = group.schedule || group.build_schedule
        schedule = group.schedules.build(schedule_params)

        # 各プランの投票数を集計し、一番多い票数（最大値）を求める
        max_votes = target_plans.map { |p| p.votes.count }.max || 0

        # 最高票数を獲得しているプランをすべて集める
        top_plans = target_plans.select { |p| p.votes.count == max_votes }

        # 🎲 同票（複数）なら .sample でランダムに1つ絞り込む！ 単独ならそのまま！
        winning_plan = if top_plans.count > 1
                         top_plans.sample # 👈 ここでランダム抽選！
                       else
                         top_plans.first
                       end
        # ==========================================

        # 2. 自動で決定した winning_plan を使ってスケジュールをビルドする
        schedule = group.schedules.build(schedule_params)
        schedule.plan = winning_plan
        # タイトルが空ならwinning_planのタイトルを自動セットするなどの配慮も可能
        schedule.title = winning_plan.title if schedule.title.blank?

          # ActiveRecord::Base.transaction do
          #   if schedule.persisted?
          #     schedule.schedule_items.destroy_all
          #   end

          if schedule.save
            # (schedule_params)
            # ⭕️ include に :plan を忘れないことで場所・予算が消えるのを防ぐ
            group.update(deadline: nil)
            render json: schedule.reload, include: [ :schedule_items, :plan ], status: :ok
          else
            render json: { errors: schedule.errors.full_messages }, status: :unprocessable_entity
          end
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.message }, status: :unprocessable_entity
      end

      # # ⭕️ 2. 確定したスケジュールを画面に表示するために取得する
      def show
        group = current_api_v1_user.groups.find(params[:group_id])
        schedule = group.schedules.find(params[:id])

        if schedule
          render json: schedule, include: [ :schedule_items, :plan ], status: :ok
        else
          render json: { message: "まだスケジュールが確定していません" }, status: :not_found
        end
      end

      def index
        group = current_api_v1_user.groups.find(params[:group_id])
        schedules = group.schedules.includes(:plan).order(created_at: :asc)
        # schedules = group.schedules.order(created_at: :desc)
        # # schedule = group.schedule
        # if schedules.present?
        #    render json: schedule, include: [:schedule_items, :plan], status: :ok
        # else
        #     render json: { message: "まだスケジュールが確定していません" }, status: :not_found
        # end
        render json: schedules, include: [ :plan ], status: :ok
      end

      def update
        group = current_api_v1_user.groups.find(params[:group_id])

        # リーダー以外は更新不可
        if group.user_id != current_api_v1_user.id
          render json: { error: "スケジュールの編集権限がありません" }, status: :forbidden
        end
      end

      private

      # ストロングパラメータ（セキュリティ許可）
      def schedule_params
        params.require(:schedule).permit(
          :title, :date, :location, :budget, :plan_id,
          # 子要素（時間と行動のリスト）の一括保存・削除を許可する
          schedule_items_attributes: [ :id, :start_time, :end_time, :content, :_destroy ]
        )
      end
    end
  end
end
