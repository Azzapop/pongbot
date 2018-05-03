Sequel.migration do
  up do
    create_table(:matches) do
      primary_key :id
      foreign_key :winner_id
      foreign_key :loser_id
    end
  end

  down do
    drop_table(:matches)
  end
end
