# encoding: utf-8
module CatarsePayulatam::Payment
  class PayulatamController < ApplicationController
    skip_before_filter :verify_authenticity_token, :only => [:notifications]
    skip_before_filter :detect_locale, :only => [:notifications]
    skip_before_filter :set_locale, :only => [:notifications]
    skip_before_filter :force_http
    
    before_filter :setup_gateway
    
    SCOPE = "projects.backers.checkout"

    layout :false

    def review
      backer = current_user.backs.not_confirmed.find params[:id]
      # Just to render the review form
      response = @@gateway.payment({
        reference: '...',
        description: "#{backer.value} donation to #{backer.project.name}",
        amount: backer.price_in_cents,
        currency: 'COP',
        response_url: payment_success_payulatam_url(id: backer.id),
        confirmation_url: payment_notifications_payulatam_url(id: backer.id),
        language: 'es'
      })
      @form = response.form do |f|
        "<input type=\"submit\" value=\"Pagar\" />"
      end
    end

    def success
      backer = current_user.backs.find params[:id]
      begin
        response = @@gateway.Response.new(params)
        if response.valid?
          backer.update_attribute :payment_method, 'PayULatam'
          backer.update_attribute :payment_token, response.transaccion_id

          proccess!(backer, response)

          payulatam_flash_success
          redirect_to main_app.project_backer_path(project_id: backer.project.id, id: backer.id)
        else
          payulatam_flash_error
          return redirect_to main_app.new_project_backer_path(backer.project)  
        end
      rescue Exception => e
        ::Airbrake.notify({ :error_class => "PayULatam Error", :error_message => "PayULatam Error: #{e.inspect}", :parameters => params}) rescue nil
        Rails.logger.info "-----> #{e.inspect}"
        payulatam_flash_error
        return redirect_to main_app.new_project_backer_path(backer.project)
      end
    end

    def notifications
      backer = current_user.backs.find params[:id]
      response = @@gateway.Response.new(params)
      if response.valid?
        proccess!(backer, response)
        render status: 200, nothing: true
      else
        render status: 404, nothing: true
      end
    rescue Exception => e
      ::Airbrake.notify({ :error_class => "PayULatam Notification Error", :error_message => "PayULatam Notification Error: #{e.inspect}", :parameters => params}) rescue nil
      Rails.logger.info "-----> #{e.inspect}"
      render status: 404, nothing: true
    end

    protected

    def proccess!(backer, response)
      notification = backer.payment_notifications.new({
        extra_data: response.params
      })

      if response.success?
        backer.confirm!  
      elsif response.failure?
        backer.pendent!
      end
    end

    def payulatam_flash_error
      flash[:failure] = t('payulatam_error', scope: SCOPE)
    end

    def payulatam_flash_success
      flash[:success] = t('success', scope: SCOPE)
    end

    def setup_gateway
      if ::Configuration[:payulatam_username] and ::Configuration[:payulatam_key] and ::Configuration[:payulatam_merchant_id] and ::Configuration[:payulatam_account_id]
        @@gateway ||= Payulatam::Client.new({
          merchant_id: ::Configuration[:payulatam_merchant_id],
          account_id: ::Configuration[:payulatam_account_id],
          login: ::Configuration[:payulatam_username],
          key: ::Configuration[:payulatam_key],
          test: true
        })
      else
        raise "[PayULatam] payulatam_username, payulatam_key, payulatam_merchant_id and payulatam_account_id are required to make requests to PayULatam"
      end
    end

  end
end