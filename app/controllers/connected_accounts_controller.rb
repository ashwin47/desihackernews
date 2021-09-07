class ConnectedAccountsController < ApplicationController
  before_action :require_logged_in_user, only: [:twitter_connect_auth, :twitter_connect_callback,
    :twitter_disconnect, :user_onboard, :user_onboard_index]
  before_action :check_for_read_only_mode
  before_action :verify_user, only: :user_onboard_index

  def twitter_auth
    session[:twitter_state] = SecureRandom.hex
    return redirect_to Twitter.oauth_auth_url(session[:twitter_state], true)

  rescue OAuth::Unauthorized
    flash[:error] = "Twitter says we're not authenticating properly, please message the admin"
    return redirect_to "/signup"
  end

  def twitter_callback
    if session[:twitter_state].blank? || (params[:state].to_s != session[:twitter_state].to_s)
      flash[:error] = "Invalid OAuth state"
      return redirect_to "/signup"
    end

    session.delete(:twitter_state)

    tok, sec, username, email = Twitter.token_secret_and_user_from_token_and_verifier(
      params[:oauth_token], params[:oauth_verifier])

    new_user = false

    if tok.present? && email.present?
      user = User.find_by(email: email)
      if user
        @user = user
      else
        @user = User.new
        @user.username = username
        @user.email = email
        @user.password = SecureRandom.hex
        new_user = true
      end
      @user.connected_account = true
      @user.twitter_oauth_token = tok
      @user.twitter_oauth_token_secret = sec
      @user.twitter_username = username
    end

    if !@user.valid? && @user.errors[:username].present? # handle username uniq validation
      @user.username = @user.username.to_s + rand.to_s[8]
    end

    if @user.save
      session[:u] = @user.session_token
      if new_user
        flash[:success] = "Welcome to #{Rails.application.name}, " <<
                          "#{@user.username}!"
        return redirect_to "/connected_accounts/user_onboard?token=#{@user.twitter_oauth_token}"
      else
        flash[:success] = "Successfully Logged In"
      end
    else
      flash[:error] = "Invalid Auth"
    end

    return redirect_to "/"
  end

  def user_onboard_index
    @title = "User Onboarding"
    @edit_user = @user.dup
  end

  def user_onboard
    @edit_user = @user.clone

    if params[:user][:password].present?
      if @edit_user.update(user_params)
        flash.now[:success] = "Successfully updated settings."
        @user = @edit_user
        return redirect_to "/"
      else
        flash[:error] = "Invalid username."
        return redirect_to "/connected_accounts/user_onboard?token=#{@user.twitter_oauth_token}"
      end
    else
      flash[:error] = "Your current password was not entered correctly."
      return redirect_to "/connected_accounts/user_onboard?token=#{@user.twitter_oauth_token}"
    end
  end

  # Associate twitter account on settings page

  def twitter_connect_auth
    session[:twitter_state] = SecureRandom.hex
    return redirect_to Twitter.oauth_auth_url(session[:twitter_state], false)
  rescue OAuth::Unauthorized
    flash[:error] = "Twitter says we're not authenticating properly, please message the admin"
    return redirect_to "/settings"
  end

  def twitter_connect_callback
    if session[:twitter_state].blank? ||
       (params[:state].to_s != session[:twitter_state].to_s)
      flash[:error] = "Invalid OAuth state"
      return redirect_to "/settings"
    end

    session.delete(:twitter_state)

    tok, sec, username, email= Twitter.token_secret_and_user_from_token_and_verifier(
      params[:oauth_token], params[:oauth_verifier])

    if email.present? && @user.email != email
      flash[:error] = "You can only associate twitter account with the same email id"
      return redirect_to "/settings"
    end

    if tok.present? && username.present?
      @user.twitter_oauth_token = tok
      @user.twitter_oauth_token_secret = sec
      @user.twitter_username = username
      @user.save!
      flash[:success] = "Your account has been linked to Twitter user @#{username}."
    else
      return twitter_disconnect
    end

    return redirect_to "/settings"
  end

  def twitter_disconnect
    @user.twitter_oauth_token = nil
    @user.twitter_username = nil
    @user.twitter_oauth_token_secret = nil
    @user.connected_account = false
    @user.save!
    flash[:success] = "Your Twitter association has been removed."
    return redirect_to "/settings"
  end

private

  def user_params
    params.require(:user).permit(
      :username, :password
    )
  end

  def verify_user
    return redirect_to "/login" if params["token"].nil?

    if @user.twitter_oauth_token == params["token"]
      true
    else
      redirect_to "/login"
    end
  end
end
