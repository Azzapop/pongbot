class Pongbot < Sinatra::Base
  configure :production, :development do
    enable :logging
  end

  set :public_folder => "public", :static => true

  get "/" do
    puts params
    user = User.create(name: rand(7), slack_id: rand(7))
    erb :welcome
  end

  post "/record" do
    logger.info params.inspect
  end
end
