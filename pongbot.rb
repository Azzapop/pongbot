require 'json'

class Pongbot < Sinatra::Base
  configure :production, :development do
    enable :logging
  end

  set :public_folder => "public", :static => true

  get "/" do
    erb :welcome
  end

  post "/record" do
    # slack params
    # {"token"=>"", "team_id"=>"", "team_domain"=>"", "channel_id"=>"", "channel_name"=>"general", "user_id"=>"U5PAL827N", "user_name"=>"aaron", "command"=>"/pongbot", "text"=>"test test", "response_url"=>"https://hooks.slack.com/commands/T5PBY04J1/358443814534/EeABz3I4xMp5YQ5NPYTU2D6X", "trigger_id"=>"357551349650.193406004613.4aa7b53bdeee78a106cd03828a8eaa78"}
    # user type <@U5PAL827N|aaron>

    headers['Content-type'] ='application/json'
    query = params['text'].split(' ')
    if query[0] != 'record'
      return {
        "response_type": "in_channel",
        "text": "Sorry, that didn't work. Please try again."
      }.to_json
    end
    keys = [:slack_id, :name]
    winner_params = Hash[keys.zip(query[1].tr('<>', '').split('|'))]
    loser_params = Hash[keys.zip(query[2].tr('<>', '').split('|'))]

    winner = User.first(slack_id: winner_params[:slack_id])
    if winner
      winner.update(name: winner_params[:name])
    else
      winner = User.create(winner_params)
    end

    loser = User.first(slack_id: loser_params[:slack_id])
    if loser
      loser.update(name: loser_params[:name])
    else
      loser = Loser.create(loser_params)
    end

    _match = Match.record(winner: winner, loser: loser)

    logger.info 'thats all there is, there isnt anymore'

    status 200
    return {
      "response_type": "in_channel",
      "text": "Sorry, that didn't work. Please try again."
    }.to_json

    # validate token
    # find or create winner
    # find or create loser
    # create match
    # record win/loss
    # return status
  end
end
