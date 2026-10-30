class Api::V1::TasksController < ApplicationController
  before_action :authenticate_api_v1_user!

  def create
    schedule = Schedule.find(params[:schedule_id])
    task = schedule.tasks.build(task_params.merge(user_id: current_api_v1_user.id))

    if task.save
      render json: { message: "タスクが正常に作成されました", task: task }, status: :created
    else
      logger.error task.errors.full_messages
      render json: { errors: "タスクの作成に失敗しました。" }, status: :unprocessable_entity
    end

  end

  def index
    schedule = Schedule.find(params[:schedule_id])
    tasks = schedule.tasks.map { |task|
      {
        id: task.id,
        role: task.role,
        description: task.description,
        user_id: task.user_id,
        # 👇 ここで user_name（または user の name）を返しているか？
        user_name: task.user&.name, 
        completed: task.completed
      }
    }
    render json: tasks
  end

  # def index
  #   schedule = Schedule.find(params[:schedule_id])
  #   tasks = schedule.tasks.includes(:user)
  #   render json: tasks.as_json(include: :user), status: :ok
  # end

  def update
    schedule = Schedule.find(params[:schedule_id])
    task = schedule.tasks.find(params[:id])
    if task.update(task_params)
      render json: { message: "タスクが正常に更新されました", task: task }, status: :ok
    else
      logger.error task.errors.full_messages
      render json: { errors: "タスクの更新に失敗しました。" }, status: :unprocessable_entity
    end
  end

  private

  def task_params
    params.require(:task).permit(:role, :description, :completed)
  end
  
end
