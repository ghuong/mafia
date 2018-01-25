class Villager < Role
  
  def team
    MAFIA_TEAMS[:village]
  end

  def objective
    MAFIA_OBJECTIVES[:village]
  end
end