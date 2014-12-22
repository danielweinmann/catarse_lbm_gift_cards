# encoding: utf-8
class CatarseLbmGiftCards::LbmGiftCardsController < ApplicationController

  skip_before_filter :force_http
  
  layout :false

  SCOPE = 'projects.backers.review.lbm_gift_cards_info'

  COUPONS = {
    '6d560428435cee2c553e2d9766ba7116' => 32000.0,
    '1cd24cde383f36b6a5ee5e397ebb7166' => 150000.0,
    '0c4a1540321bce9640b77c4349b63e06' => 100000.0,
    'b2afda52e6e6ed3b0be9395009f691eb' => 25000.0,
    '7df4cdc46bbeadd2041a2abca7071a93' => 25000.0,
    '4525b27dca6b667711f8e46288b42918' => 100000.0,
    '8b31aaadc03682a9b4a292012627bf7c' => 25000.0,
    '82ad51c8f71e6564bd104775470ceb55' => 100000.0,
    'a555c682902af4f8dced9a2fbe80a325' => 25000.0,
    '7646da28c48cd280ef480d246c7dd61d' => 25000.0,
    '8e461d0a7253dd83509eb88d19ce96e4' => 250000.0,
    '7f2f2053b50eb4c100b3cc3c4fb53f86' => 50000.0,
    '5a24cd47cda6d7e8a760284c6fb69f1f' => 25000.0,
    '0ef6810406755c0ba745df808c476eae' => 25000.0,
    '994f8b43739d2efa5ad47ea57135babf' => 25000.0
  }

  def review
  end

  def pay
    backer = current_user.backs.not_confirmed.find params[:id]
    if backer
      if COUPONS.keys.include?(Digest::MD5.hexdigest(params[:coupon]))
        if COUPONS[Digest::MD5.hexdigest(params[:coupon])] == backer.value
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
        else
          flash[:failure] = t('error_value', scope: SCOPE)
          return redirect_to main_app.new_project_backer_path(backer.project)  
        end
      else
        flash[:failure] = t('error_coupon', scope: SCOPE)
        return redirect_to main_app.new_project_backer_path(backer.project)  
      end
    else
      flash[:failure] = t('error', scope: SCOPE)
      return redirect_to main_app.new_project_backer_path(backer.project)  
    end
  end

end
