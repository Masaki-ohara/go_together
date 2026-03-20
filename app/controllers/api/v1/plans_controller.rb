module Api
    module V1
        class PlansController < ApplicationController
            def create
                 plan = Plan.new(plan_params)
                 if plan.save
                    params[:lists].each do |content|
                        next if content.blank?
                        plan.plan_items.create(content: content)
                    end
                    render json: { message: 'プランが正常に作成されました' }, status: :created
                 else
                    render json: { errors: "プランの作成に失敗しました。" }, status: :unprocessable_entity
                end
            end

            def index
                plans = Plan.all
                render json: plans, status: :ok
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
                    render json: { errors: 'プランの更新に失敗しました' }, status: :unprocessable_entity
                end
            end

            # def destroy
            #   plan = Plan.find(params[:id])
            # end
            
            private
            
            def plan_params
                params.require(:plan).permit(:date, :location, :budget, :title, plan_items_attributes: [:id, :content, :_destroy])
            end
        end
    end
end 
