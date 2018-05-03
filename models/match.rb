class Match < Sequel::Model(:matches)
  many_to_one :winner, class: :User, key: :winner_id
  many_to_one :loser, class: :User, key: :loser_id

  dataset_module do
    def record(winner: nil, loser: nil)
      return nil if winner.nil? || loser.nil?
      return Match.create(winner: winner, loser: loser)
    end
  end
end
