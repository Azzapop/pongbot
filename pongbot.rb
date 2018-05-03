class Pongbot < Sinatra::Base

  set :public_folder => "public", :static => true

  get "/" do
    puts params
    user = User.create(name: rand(7), slack_id: rand(7))
    puts user.inspect
    erb :welcome
  end

  post "/record" do
    puts params
  end
end
