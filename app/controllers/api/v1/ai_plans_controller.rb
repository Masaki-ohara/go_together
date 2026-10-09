module Api
  module V1
    class AiPlansController < ApplicationController
      before_action :authenticate_api_v1_user!

      def create
        group = current_api_v1_user.groups.find(params[:group_id])

        item_count = params[:item_count] || params[:itemCount] || 3

        # AI によるデータ生成
        generated_data = AiPlanGeneratorService.new(
          location: params[:location],
          budget: params[:budget],
          theme: params[:theme],
          item_count: item_count
        ).call

        # トランザクション内で親モデルと子モデルを一括保存
        ActiveRecord::Base.transaction do
          # params と AI 生成データを取りまとめて Plan をビルド
          @plan = group.plans.build(
            title: generated_data[:title],
            location: params[:location],
            budget: params[:budget],
            date: params[:date] || Date.today,
            created_by: "ai",
            prompt: "場所: #{params[:location]}, 予算: #{params[:budget]}円程度, テーマ・雰囲気: #{params[:theme]}"
          )

          # 子要素（plan_items）を追加
          generated_data[:items].each do |item|
            @plan.plan_items.build(
              content: item[:content],
              start_time: item[:start_time],
              end_time: item[:end_time],
              category: item[:time]
            )
          end

          # 親・子をまとめて保存
          @plan.save!
        end

        render json: @plan, include: [:plan_items], status: :created

      rescue ActiveRecord::RecordNotFound => e
        render json: { error: "指定されたグループが見つかりません" }, status: :not_found
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
      rescue => e
        render json: { error: e.message }, status: :internal_server_error
      end

      private

      def ai_plan_params
        params.permit(:location, :budget, :theme, :date, :group_id, :item_count, prompt: [:location, :budget, :theme])
      end
    end
  end
end