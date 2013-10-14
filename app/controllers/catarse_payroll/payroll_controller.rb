# encoding: utf-8
class CatarsePayroll::PayrollController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:notifications]
  skip_before_filter :detect_locale, :only => [:notifications]
  skip_before_filter :set_locale, :only => [:notifications]
  skip_before_filter :force_http
  
  before_filter :setup_payroll
  
  SCOPE = "projects.backers.checkout"

  layout :false

  def review
    backer = current_user.backs.not_confirmed.find params[:id]
    if backer
      backer.update_attribute :payment_method, 'Payroll'
      payment = @@payroll.payment({
        reference: backer.key,
        description: t('payroll_description', scope: SCOPE, :project_name => backer.project.name, :value => backer.display_value),
        amount: backer.value,
        currency: t('number.currency.format.unit'),
        response_url: respond_payroll_url(backer),
        confirmation_url: confirm_payroll_url(backer),
        language: I18n.locale.to_s
      })
      @form = payment.form do |f|
        "<div class=\"bootstrap-twitter\"><input class=\"btn btn-primary btn-large\" name=\"commit\" type=\"submit\" value=\"#{t('payroll_submit', scope: SCOPE)}\" /></div>"
      end
    end
  end

  def respond
    backer = current_user.backs.find params[:id]
    begin
      if proccess_payroll_response(backer, params)
        flash[:success] = t('success', scope: SCOPE)
        redirect_to main_app.project_backer_path(project_id: backer.project.id, id: backer.id)
      else
        flash[:failure] = t('payroll_error', scope: SCOPE)
        return redirect_to main_app.new_project_backer_path(backer.project)  
      end
    rescue Exception => e
      Rails.logger.info "Payroll Response Error -----> #{e.inspect}"
      flash[:failure] = t('payroll_error', scope: SCOPE)
      return redirect_to main_app.new_project_backer_path(backer.project)
    end
  end

  def confirm
    backer = Backer.find params[:id]
    if proccess_payroll_response(backer, params)
      render status: 200, nothing: true
    else
      render status: 422, nothing: true
    end
  rescue Exception => e
    Rails.logger.info "Payroll Confirmation Error -----> #{e.inspect}"
    render status: 500, nothing: true
  end

  protected

  def proccess_payroll_response(backer, params)
    PaymentEngines.create_payment_notification backer_id: backer.id, extra_data: params
    payroll_response = Payroll::Response.new(@@payroll, params)
    return unless payroll_response.valid?
    return unless backer.payment_method == "Payroll" && backer.key == payroll_response.reference
    backer.update_attribute :payment_id, payroll_response.transaction_id
    if payroll_response.success?
      backer.confirm!  
    elsif payroll_response.failure?
      backer.pendent!
    else
      backer.waiting! if backer.pending?
    end
    true
  end

  def setup_payroll
    if PaymentEngines.configuration[:payroll_login] and PaymentEngines.configuration[:payroll_key] and PaymentEngines.configuration[:payroll_merchant] and PaymentEngines.configuration[:payroll_account]
      @@payroll ||= Payroll::Client.new({
        merchant_id: PaymentEngines.configuration[:payroll_merchant],
        account_id: PaymentEngines.configuration[:payroll_account],
        login: PaymentEngines.configuration[:payroll_login],
        key: PaymentEngines.configuration[:payroll_key],
        test: (PaymentEngines.configuration[:payroll_test] == "true")
      })
    else
      raise "[Payroll] payroll_merchant, payroll_account, payroll_login and payroll_key are required configurations to make requests to Payroll"
    end
  end

end
