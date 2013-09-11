# encoding: utf-8
class CatarsePayulatam::PayulatamController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:notifications]
  skip_before_filter :detect_locale, :only => [:notifications]
  skip_before_filter :set_locale, :only => [:notifications]
  skip_before_filter :force_http
  
  before_filter :setup_payulatam
  
  SCOPE = "projects.backers.checkout"

  layout :false

  def review
    backer = current_user.backs.not_confirmed.find params[:id]
    if backer
      transaction_id = (Digest::MD5.hexdigest "#{SecureRandom.hex(5)}-#{DateTime.now.to_s}")[1..20].downcase
      backer.update_attribute :payment_method, 'PayULatam'
      backer.update_attribute :payment_token, transaction_id
      payment = @@payulatam.payment({
        reference: transaction_id,
        description: t('payulatam_description', scope: SCOPE, :project_name => backer.project.name, :value => backer.display_value),
        amount: backer.value,
        currency: t('number.currency.format.unit'),
        response_url: respond_payulatam_url(backer),
        confirmation_url: confirm_payulatam_url(backer),
        language: I18n.locale.to_s
      })
      @form = payment.form do |f|
        "<div class=\"bootstrap-twitter\"><input class=\"btn btn-primary btn-large\" name=\"commit\" type=\"submit\" value=\"#{t('payulatam_submit', scope: SCOPE)}\" /></div>"
      end
    end
  end

  def respond
    backer = current_user.backs.find params[:id]
    begin
      if proccess_payulatam_response(backer, params)
        flash[:success] = t('success', scope: SCOPE)
        redirect_to main_app.project_backer_path(project_id: backer.project.id, id: backer.id)
      else
        flash[:failure] = t('payulatam_error', scope: SCOPE)
        return redirect_to main_app.new_project_backer_path(backer.project)  
      end
    rescue Exception => e
      Rails.logger.info "PayULatam Response Error -----> #{e.inspect}"
      flash[:failure] = t('payulatam_error', scope: SCOPE)
      return redirect_to main_app.new_project_backer_path(backer.project)
    end
  end

  def confirm
    backer = Backer.find params[:id]
    if proccess_payulatam_response(backer, params)
      render status: 200, nothing: true
    else
      render status: 422, nothing: true
    end
  rescue Exception => e
    Rails.logger.info "PayULatam Confirmation Error -----> #{e.inspect}"
    render status: 500, nothing: true
  end

  protected

  def proccess_payulatam_response(backer, params)
    PaymentEngines.create_payment_notification backer_id: backer.id, extra_data: params
    payulatam_response = Payulatam::Response.new(@@payulatam, params)
    return unless payulatam_response.valid?
    return unless backer.payment_method == "PayULatam" && backer.payment_token == payulatam_response.reference
    if payulatam_response.success?
      backer.confirm!  
    elsif payulatam_response.failure?
      backer.pendent!
    else
      backer.waiting! if backer.pending?
    end
    true
  end

  def setup_payulatam
    if PaymentEngines.configuration[:payulatam_login] and PaymentEngines.configuration[:payulatam_key] and PaymentEngines.configuration[:payulatam_merchant] and PaymentEngines.configuration[:payulatam_account]
      @@payulatam ||= Payulatam::Client.new({
        merchant_id: PaymentEngines.configuration[:payulatam_merchant],
        account_id: PaymentEngines.configuration[:payulatam_account],
        login: PaymentEngines.configuration[:payulatam_login],
        key: PaymentEngines.configuration[:payulatam_key],
        test: (PaymentEngines.configuration[:payulatam_test] == "true")
      })
    else
      raise "[PayULatam] payulatam_merchant, payulatam_account, payulatam_login and payulatam_key are required configurations to make requests to PayULatam"
    end
  end

end
