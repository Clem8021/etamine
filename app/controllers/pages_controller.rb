class PagesController < ApplicationController
  before_action :require_preview_access, only: [
    :mariage_fleuriste,
    :mariage_wedding,
    :galerie
  ]

  def home; end
  def about; end
  def contact; end
  def cgv; end

  def mariage_fleuriste; end
  def mariage_wedding; end
  def galerie; end
end
