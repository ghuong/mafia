MAFIA_TEAMS = {
  village: "Village",
  mafia: "Mafia",
  solo: "Solo"
}.freeze

MAFIA_ROLES = [
  {
    name: "Villager",
    team: MAFIA_TEAMS[:village]
  },
  {
    name: "Mafia",
    team: MAFIA_TEAMS[:mafia]
  }
].freeze