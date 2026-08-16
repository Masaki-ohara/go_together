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
# app/controllers/api/v1/schedules_controller.rb
module Api
  module V1
    class SchedulesController < ApplicationController
      before_action :authenticate_api_v1_user!

      # ⭕️ 1. スケジュールを新規作成・上書き保存する
      def create
        group = current_api_v1_user.groups.find(params[:group_id])
        
        # すでにグループにスケジュールがあれば上書き、無ければ新しく作る
        schedule = group.schedule || group.build_schedule
        
        if schedule.update(schedule_params)
          # 画面表示に必要な schedule_items も一緒にまとめてReactに返す
          render json: schedule, include: :schedule_items, status: :ok
        else
          render json: { errors: schedule.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # ⭕️ 2. 確定したスケジュールを画面に表示するために取得する
      def show
        group = current_api_v1_user.groups.find(params[:group_id])
        schedule = group.schedule
        
        if schedule
          render json: schedule, include: :schedule_items, status: :ok
        else
          render json: { message: "まだスケジュールが確定していません" }, status: :not_found
        end
      end

      def index
        group = current_api_v1_user.groups.find(params[:group_id])
        schedule = group.schedule
        if schedule
            render json: schedule, include: :schedule_items, status: :ok
        else
            render json: { message: "まだスケジュールが確定していません" }, status: :not_found
        end
      end

      private

      # ストロングパラメータ（セキュリティ許可）
      def schedule_params
        params.require(:schedule).permit(
          :title, :date,
          # 子要素（時間と行動のリスト）の一括保存・削除を許可する
          schedule_items_attributes: [:id, :start_time, :end_time, :content, :_destroy]
        )
      end
    end
  end
end
