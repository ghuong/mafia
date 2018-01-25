class Role

  TARGET_NOBODY = -1.freeze
  TARGET_UNDECIDED = -2.freeze

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
    "Villager", "Mafia", "Cop", "Doctor"
  ].freeze

  ACTIONS = {
    kill: { name: "kill", description: "Vote to Kill" },
    lynch: { name: "lynch", description: "Vote to Lynch" },
    investigate: { name: "investigate", description: "Investigate" },
    heal: { name: "heal", description: "Heal" }
  }.freeze

  #  Get the role object according to its 'id'
  def self.get_role(id, user = nil)
    role_name = MAFIA_ROLES[id]
    case role_name
    when "Villager"
      Villager.new(id, user)
    when "Mafia"
      MafiaRole.new(id, user)
    when "Cop"
      Cop.new(id, user)
    when "Doctor"
      Doctor.new(id, user)
    end
  end

  def initialize(action_id, user = nil)
    @action_id = action_id
    @name = MAFIA_ROLES[action_id]
    set_user(user)
  end

  def set_user(user)
    if user
      @user = user
      @room = @user.room
      @all_users = @room.users
      @living_users = @all_users.select { |u| u.is_alive }
    end
  end

  def get_action_options
    actions = []

    case @room.day_phase
    when 'night'
      actions.push(*get_night_actions)
    when 'day'
      actions.push(*get_lynch_actions)
      actions.push(*get_day_actions)
    end

    selected_targets = @user.get_action_targets
    actions.each_with_index do |action, idx|
      action[:id] = idx

      if !selected_targets.empty?
        action[:selected] = selected_targets[idx]
      end

      # Show other votes for certain actions
      action[:other_votes] = []
      add_other_votes(action, idx)
    end

    return actions
  end

  # Process user's independent actions (e.g. Cop, Doctor, Vigilante)
  # Add any killed users to list
  def process_independent_actions(killed_users)
     case @room.day_phase
      when 'night'
        process_night_actions(killed_users)
      when 'day'
        process_day_actions(killed_users)
      end
  end

  # Retrieve the User corresponding to a target
  def self.resolve_target(target_id)
    case target_id
    when TARGET_NOBODY
      User.new(id: target_id, name: "Nobody")
    when TARGET_UNDECIDED
      User.new(id: target_id, name: "Undecided")
    else
      User.find_by(id: target_id)
    end
  end

  def id
    @action_id
  end

  def name
    @name
  end

  def team
    ""
  end

  def objective
    ""
  end

  def ability
    ""
  end

  protected
    
    # Returns an array of formatted actions (via format_action)
    def get_night_actions
      []
    end

    # Returns an array of formatted actions (via format_action)
    def get_day_actions
      []
    end

    # Returns an array of formatted actions (via format_action)
    def get_lynch_actions
      targets = @living_users.map { |user| format_target(user) }

      targets.unshift(get_nobody_target)
      targets.unshift(get_undecided_target)

      [format_action(ACTIONS[:lynch][:name], ACTIONS[:lynch][:description], targets)]
    end

    def add_other_votes(action, action_idx, more_users = [])
      other_users = case action[:name]
      when ACTIONS[:lynch][:name]
        @living_users.select { |u| u != @user }
      else
        []
      end

      other_users += more_users
      
      add_other_votes_helper(action, action_idx, other_users)
    end

    def process_night_actions(killed_users)
    end

    def process_day_actions(killed_users)
    end

  private

    def add_other_votes_helper(action, action_idx, other_users)
      action[:other_votes] += other_users.map do |user|
        vote = Role::resolve_target(user.get_action_target(action_idx)).name
        format_other_vote(user, vote)
      end
    end

    # Returns a hash representing an action for a role
    def format_action(action_name, action_description, targets)
      { name: action_name, description: action_description, targets: targets }
    end

    # Returns a hash representing a target for an action
    def format_target(user)
      { user_id: user.id, name: user.name }
    end

    # Returns a hash representing another player's vote of the same action
    def format_other_vote(user, vote)
      { user_id: user.id, user_name: user.name, vote: vote, is_ready: user.is_ready }
    end

    # Returns a hash representing a target when user is undecided
    def get_undecided_target
      { user_id: TARGET_UNDECIDED, name: "Choose someone:" }
    end

    # Returns a hash representing a target on nobody
    def get_nobody_target
      { user_id: TARGET_NOBODY, name: "Nobody" }
    end

end