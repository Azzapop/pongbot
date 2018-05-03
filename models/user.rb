class User < Sequel::Model(:users)
  one_to_many :won_matches, class: :Match, key: :winner_id
  one_to_many :lost_matches, class: :Match, key: :loser_id
  many_to_many :defeated_opponents, left_key: :winner_id, right_key: :loser_id, join_table: :matches, class: self
  many_to_many :undefeated_opponents, left_key: :loser_id, right_key: :winner_id, join_table: :matches, class: self

  def before_create
    super
    self.elo = 1500
  end

  def matches
    won_matches + lost_matches
  end

  def opponents
    defeated_opponents + undefeated_opponents
  end
end
