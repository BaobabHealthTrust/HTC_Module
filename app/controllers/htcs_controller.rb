class HtcsController < ApplicationController
  before_action :set_htc, only: [:show, :edit, :update, :destroy]

  def index
    @htcs = [1,2,3]
  end

end
