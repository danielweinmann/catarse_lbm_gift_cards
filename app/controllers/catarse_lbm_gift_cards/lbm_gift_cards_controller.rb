# encoding: utf-8
class CatarseLbmGiftCards::LbmGiftCardsController < ApplicationController

  skip_before_filter :force_http
  
  layout :false

  SCOPE = 'projects.backers.review.lbm_gift_cards_info'

  def review
  end

  def pay
    backer = current_user.backs.not_confirmed.find params[:id]
    if backer
      response = HTTParty.put("https://lbmgiftcards.herokuapp.com/gift_cards/#{params[:coupon]}/redeem", headers: {'Authorization' => "Token token=\"#{PaymentEngines.configuration[:lbm_gift_cards_api_key]}\""}, body: { value: backer.value.to_i })
      case response.code
      when 200, 204, 406
        if Backer.confirmed.where(payment_method: 'LbmGiftCard', payment_id: params[:coupon]).count == 0
          backer.update_attribute :payment_method, 'LbmGiftCard'
          backer.update_attribute :payment_id, params[:coupon]
          backer.confirm!
          flash[:success] = t('success', scope: SCOPE)
          redirect_to main_app.project_backer_path(project_id: backer.project.id, id: backer.id)
        else
          flash[:failure] = t('error_duplicate', scope: SCOPE)
          return redirect_to main_app.new_project_backer_path(backer.project)  
        end
      when 404
        flash[:failure] = t('error_coupon', scope: SCOPE)
        return redirect_to main_app.new_project_backer_path(backer.project)  
      when 422
        error = JSON.parse(response.body)["error"]
        case error
        when 'wrong_value'
          flash[:failure] = t('error_value', scope: SCOPE)
          return redirect_to main_app.new_project_backer_path(backer.project)  
        when 'cant_redeem'
          flash[:failure] = t('error_duplicate', scope: SCOPE)
          return redirect_to main_app.new_project_backer_path(backer.project)  
        else
          flash[:failure] = t('error', scope: SCOPE)
          return redirect_to main_app.new_project_backer_path(backer.project)  
        end
      else
        flash[:failure] = t('error', scope: SCOPE)
        return redirect_to main_app.new_project_backer_path(backer.project)  
      end
    else
      flash[:failure] = t('error', scope: SCOPE)
      return redirect_to main_app.new_project_backer_path(backer.project)  
    end
  end

end
