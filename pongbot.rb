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

    if params['token'] != ENV['SLACK_TOKEN']
      status 403
      return "Invalid Token"
    end

    query = params['text'].split(' ')
    case query[0]
    when 'record'
      winner = User.find_or_create_by_slack_id(slack_id: query[1])
      loser = User.find_or_create_by_slack_id(slack_id: query[2])
      logger.info "WINNER: " + winner.inspect
      logger.info "LOSER: " + loser.inspect
      unless winner.errors.any? || loser.errors.any?
        match = Match.record(winner: winner, loser: loser)
        unless match.errors.any?
          response[:text] = ':zap: :ping_pong:'
          response[:attachments] << { text: "#{winner.name} has beaten #{loser.name}", color: "#00BD58" }
          response[:attachments] += Match.slack_leaderboard(heading: 'New Leaderboard')
        else
          response[:text] = match.errors.join(', ')
        end
      else
        response[:text] = (winner.errors + loser.errors).join(', ')
      end
    when 'odds'
      player1 = User.find_or_create_by_slack_id(slack_id: query[1])
      player2 = User.find_or_create_by_slack_id(slack_id: query[2])
      logger.info player1.inspect
      logger.info player2.inspect
      player1_odds = player1.expected_odds(opponent_elo: player2.elo)
      player2_odds = player2.expected_odds(opponent_elo: player1.elo)
      response[:text] = "#{player1.screen_name} (#{player1_odds}) -- #{player2.screen_name} (#{player2_odds})"
    when 'matches'
      player = User.find_or_create_by_slack_id(slack_id: query[1])
      response[:attachments] << {
        text: 'Match List',
        fields: [
          { title: 'Winner', short: true },
          { title: 'Loser', short: true }
        ],
        color: '#2b2626'
      }
      response[:attachments] += player.matches.map do |m|
        {
          fields: [
            { value: m.winner.screen_name, short: true },
            { value: m.loser.screen_name, short: true }
          ]
        }
      end
    when 'leaderboard'
      response[:text] = ':ping_pong: Leaderboard :ping_pong:'
      response[:attachments] = Match.slack_leaderboard
    when 'wipe'
      User.all.each { |u| u.delete }
      response[:text] = 'Deleted all users.'
    when 'log'
      logger.info "======================="
      logger.info "Logging Users"
      User.top_ten.each { |u| logger.info u.inspect }
      logger.info "======================="
      response[:text] = 'Logging done.'
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
