class SignupController < ApplicationController
  before_action :require_logged_in_user, :check_new_users, :check_can_invite, :only => :invite
  before_action :check_for_read_only_mode

  def index
    if @user
      flash[:error] = "You are already signed up."
      return redirect_to "/"
    end
    if Rails.application.open_signups?
      redirect_to action: :invited, invitation_code: 'open' and return
    end
    @title = "Signup"
  end

  def invite
    @title = "Pass Along an Invitation"
  end

  def invited
    if @user
      flash[:error] = "You are already signed up."
      return redirect_to "/"
    end

    if !Rails.application.open_signups?
      if !(@invitation = Invitation.unused.where(:code => params[:invitation_code].to_s).first)
        flash[:error] = "Invalid or expired invitation"
        return redirect_to "/signup"
      end
    end

    @title = "Signup"

    @new_user = User.new

    if !Rails.application.open_signups?
      @new_user.email = @invitation.email
    end

    render :action => "invited"
  end

  def signup
    if !Rails.application.open_signups?
      if !(@invitation = Invitation.unused.where(:code => params[:invitation_code].to_s).first)
        flash[:error] = "Invalid or expired invitation."
        return redirect_to "/signup"
      end
    end

    @title = "Signup"

    @new_user = User.new(user_params)

    if !Rails.application.open_signups?
      @new_user.invited_by_user_id = @invitation.user_id
    end

    if @new_user.save
      if @invitation
        @invitation.update(used_at: Time.current, new_user: @new_user)
      end
      session[:u] = @new_user.session_token
      flash[:success] = "Welcome to #{Rails.application.name}, " <<
                        "#{@new_user.username}!"

      if Rails.application.allow_new_users_to_invite?
        return redirect_to signup_invite_path
      else
        return redirect_to root_path
      end
    else
      render :action => "invited"
    end
  end

  def twitter_auth
    session[:twitter_state] = SecureRandom.hex
    return redirect_to Twitter.oauth_auth_url(session[:twitter_state])
  rescue OAuth::Unauthorized
    flash[:error] = "Twitter says we're not authenticating properly, please message the admin"
    return redirect_to "/signup"
  end

  def twitter_callback
    if session[:twitter_state].blank? ||
       (params[:state].to_s != session[:twitter_state].to_s)
      flash[:error] = "Invalid OAuth state"
      return redirect_to "/signup"
    end

    session.delete(:twitter_state)

    tok, sec, username = Twitter.token_secret_and_user_from_token_and_verifier(
      params[:oauth_token], params[:oauth_verifier])
    if tok.present? && username.present?
      @user.twitter_oauth_token = tok
      @user.twitter_oauth_token_secret = sec
      @user.twitter_username = username
      @user.save!
      flash[:success] = "Your account has been linked to Twitter user @#{username}."
    else
      return twitter_disconnect
    end

    return redirect_to "/signup" #root_path
  end

private

  def check_new_users
    if !Rails.application.allow_new_users_to_invite? && @user.is_new?
      redirect_to root_path, flash: { error: "New users cannot send invites" }
    end
  end

  def check_can_invite
    if !@user.can_invite?
      redirect_to root_path, flash: { error: "You can't send invites" }
    end
  end

  def user_params
    params.require(:user).permit(
      :username, :email, :password, :password_confirmation, :about,
    )
  end
end
