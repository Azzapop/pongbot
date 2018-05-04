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

    status 200
    headers['Content-type'] ='application/json'
    response = {
      response_type: "in_channel",
      text: "Sorry that didn't work. Please try again.",
      attachments: []
    }

    logger.info User.count
    logger.info User.top_ten.inspect
    if params['token'] != ENV['SLACK_TOKEN']
      status 403
      return "Invalid Token"
    end

    query = params['text'].split(' ')
    if query[0] == 'record'
      winner = User.find_or_create_by_slack_id(slack_id: query[1])
      loser = User.find_or_create_by_slack_id(slack_id: query[2])
      unless winner.errors.any? || loser.errors.any?
        match = Match.record(winner: winner, loser: loser)
        unless match.errors.any?
          response[:text] = winner.inspect + " -- " + loser.inspect
          response[:attachments] << { text: "#{winner.name} has beaten #{loser.name}", color: "#00BD58" }
          response[:attachments] << {
            text: 'New Leaderboard',
            fields: [
              { title: 'Position', short: true },
              { title: 'Player (W/L)', short: true }
            ],
            color: '#2b2626'
          }
          response[:attachments] << User.top_ten.each_with_index.map do |user, i|
            {
              fields: [
                { title: '', value: i, short: true },
                { title: '', value: "#{user.name} (#{user.won_matches.count}/#{user.lost_matches.count})", short: true }
              ]
            }
          end
        else
          response[:text] = match.errors.join(', ')
        end
      else
        response[:text] = (winner.errors + loser.errors).join(', ')
      end
    end

    return response.to_json

    # validate token
    # find or create winner
    # find or create loser
    # create match
    # record win/loss
    # return status
  end
end
