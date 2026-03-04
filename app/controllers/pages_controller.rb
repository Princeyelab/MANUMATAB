class PagesController < ApplicationController
  def home
    @interview = Interview.new
  end
end
