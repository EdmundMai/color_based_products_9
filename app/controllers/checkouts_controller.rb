class CheckoutsController < ApplicationController
  
  before_action :prevent_cache, only: [:billing]
  
  def add_to_cart
    @cart = current_or_guest_user.cart
    @cart.add_item!(params[:variant_id], params[:quantity])
    respond_to do |format|
      format.html { redirect_to checkout_path }
    end
  end
  
  def show
  end
  
  def billing
    @order = current_or_guest_user.last_incomplete_order
    @site_wide_coupon = Coupon.active.site_wide.last
    if current_user
      @payment_info = PaymentInfo.new(
                                  shipping_address_first_name: @order.shipping_address.try(:first_name),
                                  shipping_address_last_name: @order.shipping_address.try(:last_name),
                                  shipping_address_street_address: @order.shipping_address.try(:street_address),
                                  shipping_address_street_address2: @order.shipping_address.try(:street_address2),
                                  shipping_address_zip_code: @order.shipping_address.try(:zip_code),
                                  shipping_address_city: @order.shipping_address.try(:city),
                                  shipping_address_state_id: @order.shipping_address.try(:state_id),
                                  shipping_address_phone_number: @order.shipping_address.try(:phone_number),
                                  billing_address_first_name: @order.billing_address.try(:first_name),
                                  billing_address_last_name: @order.billing_address.try(:last_name),
                                  billing_address_street_address: @order.billing_address.try(:street_address),
                                  billing_address_street_address2: @order.billing_address.try(:street_address2),
                                  billing_address_zip_code: @order.billing_address.try(:zip_code),
                                  billing_address_city: @order.billing_address.try(:city),
                                  billing_address_state_id: @order.billing_address.try(:state_id),
                                  billing_address_phone_number: @order.billing_address.try(:phone_number),
                                  order_id: @order.id
                                  )
    else
      @payment_info = PaymentInfo.new(order_id: @order.id)
    end
  end
  
  def signup_user
    if current_or_guest_user.update_attributes(guest_user_params)
      sign_in(current_or_guest_user)
    end
    respond_to do |format|
      format.js
    end
  end
  
  def update_billing
    @order = current_user.last_incomplete_order
    @payment_info = PaymentInfo.new(params[:payment_info].merge(order_id: @order.id))
    @payment_info.save
    respond_to do |format|
      format.js
    end
  end
  
  def submit_order
    @usaepay = UsaepayWrapper.new(params[:credit_card])
    if @usaepay.authorize
      order = current_or_guest_user.last_incomplete_order
      order.finalize!
      delete_sensitive_session_variables!
      render js: "window.location = '#{review_checkout_path}'"
    else
      respond_to do |format|
        format.js
      end
    end
  end
  
  def login_user
    @user = User.find_by_email(params[:user][:email])
    if @user && @user.valid_password?(params[:user][:password])
      login_process do 
        sign_in(@user)
      end
    end
    respond_to do |format|
      format.js
    end
  end
  
  def review
  end
  
  
  
  private
  
    def guest_user_params
      params.require(:user).permit(:email, :password, :guest)
    end
  
    def delete_sensitive_session_variables!
      cookies.delete(:guest_user_id)
    end

  
end