class Match < Sequel::Model(:matches)
  many_to_one :winner, class: :User, key: :winner_id
  many_to_one :loser, class: :User, key: :loser_id

  def validate
    super
    errors.add(:winner, 'No winner provided.') unless winner
    errors.add(:loser, 'No loser provider') unless loser
  end

  dataset_module do
    def record(winner: nil, loser: nil)
      match = Match.create(winner: winner, loser: loser)
      unless match.errors.any?
        winner_elo, loser_elo = winner.elo, loser.elo
        winner.update_elo(opponent_elo: loser_elo, won: true)
        loser.update_elo(opponent_elo: winner_elo, won: false)
      end
      return match
    end

    def slack_leaderboard(heading: '')
      board = [{
        text: heading,
        fields: [
          { title: 'Position', short: true },
          { title: 'Player (W/L)', short: true }
        ],
        color: '#2b2626'
      }]
      board += User.top_ten.each_with_index.map do |user, i|
        {
          fields: [
            { title: '', value: i+1, short: true },
            { title: '', value: "#{user.name || user.slack_id} (#{user.won_matches.count}/#{user.lost_matches.count})", short: true }
          ]
        }
      end
      return board
    end
  end
end
