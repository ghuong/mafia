MAFIA_TEAMS = {
  village: "Village",
  mafia: "Mafia",
  solo: "Solo"
}.freeze

MAFIA_OBJECTIVES = {
  village: "All Villagers win, regardless of whether they're alive, when all the Mafia are killed.",
  mafia: "All Mafia members win, regardless of whether they're alive, when half the surviving players are Mafia."
}.freeze

MAFIA_ROLES = [
  {
    name: "Villager",
    team: MAFIA_TEAMS[:village],
    objective: MAFIA_OBJECTIVES[:village],
    ability: ""
  },
  {
    name: "Mafia",
    team: MAFIA_TEAMS[:mafia],
    objective: MAFIA_OBJECTIVES[:mafia],
    ability: "At night, each Mafia votes for a victim. Of the victims with the most votes, one will be killed at random."
  },
  {
    name: "Cop",
    team: MAFIA_TEAMS[:village],
    objective: MAFIA_OBJECTIVES[:village],
    ability: "At night, you investigate another player. In the morning, you learn whether or not they are Mafia."
  }
].freeze
