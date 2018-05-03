Sequel.migration do
  up do
    add_column :users, :elo, Integer
    from(:users).update(elo: 1500)
  end

  down do
    drop_column :users, :elo
  end
end
