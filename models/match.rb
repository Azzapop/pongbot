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
        winner.update_elo(opponent_elo: loser.elo, won: true)
        loser.update_elo(opponent_elo: winner.elo, won: false)
      end
      return match
    end
  end
end
