module Backoffice
  class BaseController < ApplicationController
    before_action :authenticate_admin!
    layout "backoffice"
  end
end
