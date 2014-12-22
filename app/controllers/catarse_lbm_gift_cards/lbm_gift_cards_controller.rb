# encoding: utf-8
class CatarseLbmGiftCards::LbmGiftCardsController < ApplicationController

  skip_before_filter :force_http
  
  layout :false

  SCOPE = 'projects.backers.review.lbm_gift_cards_info'

  def review
    @companies = t('companies', scope: SCOPE).split(',').map(&:strip)
  rescue
    @companies = []
  end

  def pay
    backer = current_user.backs.not_confirmed.find params[:id]
    if backer
      backer.update_attribute :payment_method, 'LbmGiftCard'
      backer.update_attribute :payment_choice, params[:company_name]
      backer.update_attribute :payment_id, params[:employee_id]
      backer.waiting!
      flash[:success] = t('success', scope: SCOPE)
      redirect_to main_app.project_backer_path(project_id: backer.project.id, id: backer.id)
    else
      flash[:failure] = t('error', scope: SCOPE)
      return redirect_to main_app.new_project_backer_path(backer.project)  
    end
  end

end
