class ReleasesController < ApplicationController
  def show
  end

  def index
    @releases = Release.all
  end
end
