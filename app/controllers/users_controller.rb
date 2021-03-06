class UsersController < ApplicationController
  
  before_filter :set_client
  
  
  def connect
      request_token = @client.request_token(
        :oauth_callback => "http://twitterkioskapp.com/users/auth"
      )
      session[:request_token] = request_token.token
      session[:request_token_secret] = request_token.secret
      redirect_to request_token.authorize_url.gsub('authorize', 'authenticate')
  end
  
  
  def auth
    begin
      @access_token = @client.authorize(
         session[:request_token],
         session[:request_token_secret],
         :oauth_verifier => params[:oauth_verifier]
       )
     rescue OAuth::Unauthorized
       logger.info("Cannot log in")
     end

     if @client.authorized?
         # Storing the access tokens so we don't have to go back to Twitter again
         # in this session.  In a larger app you would probably persist these details somewhere.
         session[:access_token] = @access_token.token
         session[:secret_token] = @access_token.secret
         flash[:notice] = "You are now authenticated using OAuth for Twitter. Click show to start kiosk!"
         redirect_to '/kiosks'
       else
         redirect_to '/'
     end
  end
  
end
