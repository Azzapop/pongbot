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

  def update_elo(opponent_elo: 1500, won: false)
    k = 32
    expected = 1/(1+10**((opponent_elo-elo)/400))
    new_elo = elo + (k*((won ? 1 : 0) - expected))
    self.elo = new_elo
  end

  dataset_module do
    def find_or_create_by_slack_id(slack_id: nil)
      return User.new.errors.add(:slack_id, 'Missing a slack id.') if slack_id.nil?

      keys = [:slack_id, :name]
      user_params = Hash[keys.zip(slack_id.tr('<>', '').split('|'))]
      user = User.first(slack_id: user_params[:slack_id])
      user = if user
        user.update(name: user_params[:name])
      else
        User.create(user_params)
      end
      return user
    end
  end
end
