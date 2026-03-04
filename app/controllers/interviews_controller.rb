class InterviewsController < ApplicationController
  before_action :authenticate_user!

  def index
    @interviews = Interview.all
  end

  def show
    @interview = Interview.find(params[:id])
  end
end
