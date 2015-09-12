RSpec.describe "end-to-end flow" do

  it "can go from beginning to end" do
    # create a user
    post "/v1/users", { data: { type: "users", attributes: { username: "sean", password: "drowssap" } } }.to_json, { "Content-Type" => "application/vnd.api+json" }
    user_id = JSON.parse(response.body)["data"]["id"]
    expect(user_id).not_to be_nil

    # generate a token for the user
    post "/oauth/token", { "grant_type" => "password", "username" => "sean", password: "drowssap" }
    expect(response.status).to eq 200
    access_token = JSON.parse(response.body)["access_token"]
    expect(access_token).not_to be_blank

    # create a player
    post(
      "/v1/players",
      {
        data: {
          type: "players",
          relationships: {
            user: {
              data: {
                id: user_id,
                type: "users"
              }
            }
          }
        }
      }.to_json,
      {
        "Content-Type" => "application/vnd.api+json",
        "Authorization" => "Bearer #{access_token}"
      }
    )
    player_id = JSON.parse(response.body)["data"]["id"]
    expect(player_id).not_to be_blank

    # create a table rule set
    post(
      "/v1/table-rule-sets",
      {
        data: {
          type: "table-rule-sets",
          attributes: {
            "name" => "Standard Casino",
            "deck-count" => 6,
            "player-position-count" => 5,
            "maximum-players-per-position" => 3,
            "maximum-bets-per-player" => 6,
            "no-hole-card" => false,
            "original-bets-only" => nil,
            "initial-player-card-face-up" => true,
            "blackjack-pay-out" => "1.5",
            "standard-pay-out" => "1.0",
            "dealer-stands-at" => 17,
            "dealer-draws-if-soft-stand-at" => false,
            "surrender" => "late",
            "surrender-percentage" => "0.5",
            "insurance-available" => true,
            "insurance-pay-out" => "2.0",
            "dealer-match-available" => true,
            "dealer-match-pay-out" => "2.0",
            "double-down-minimum-percentage" => "1.0",
            "double-down-maximum-percentage" => "1.0",
            "split-identical-ranks-only" => false,
            "maximum-double-count-per-hand" => nil,
            "maximum-split-count-per-hand" => nil,
            "may-hit-split-aces" => false,
            "non-controlling-player-chooses-split-hand-to-bet-if-not-following" => false,
            "player-must-stand-on-soft-21" => true,
            "restrict-doubling-to-hard-totals" => nil,
            "dealer-wins-ties" => false,
            "round-initial-betting-window-seconds" => 30,
            "minimum-wager-amount" => 25,
            "minimum-players-per-round" => 1
          }
        }
      }.to_json,
      {
        "Content-Type" => "application/vnd.api+json",
        "Authorization" => "Bearer #{access_token}"
      }
    )
    table_rule_set_id = JSON.parse(response.body)["data"]["id"]
    expect(table_rule_set_id).not_to be_nil

    # create a table
    post(
      "/v1/tables",
      {
        data: {
          type: "tables",
          relationships: {
            "table-rule-set" => {
              data: {
                type: "table-rule-sets",
                id: table_rule_set_id
              }
            }
          }
        }
      }.to_json,
      {
        "Content-Type" => "application/vnd.api+json",
        "Authorization" => "Bearer #{access_token}"
      }
    )
    table_id = JSON.parse(response.body)["data"]["id"]
    expect(table_id).not_to be_nil

    # sit the player at the table
    post(
      "/v1/table-player-positions",
      {
        data: {
          type: "table-player-positions",
          relationships: {
            "table" => {
              data: {
                type: "tables",
                id: table_id
              }
            },
            "player" => {
              data: {
                type: "players",
                id: player_id
              }
            }
          },
          attributes: {
            position: 1
          }
        }
      }.to_json,
      {
        "Content-Type" => "application/vnd.api+json",
        "Authorization" => "Bearer #{access_token}"
      }
    )
    table_player_position_one = JSON.parse(response.body)["data"]["id"]
    expect(table_player_position_one).not_to be_nil
  end

end