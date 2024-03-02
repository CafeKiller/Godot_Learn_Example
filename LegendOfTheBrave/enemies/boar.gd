extends Enemy

enum State {
	IDLE,
	WALK,
	RUN,
	HIT,
}

@onready var wall_checker: RayCast2D = $Graphics/WallChecker
@onready var player_checker: RayCast2D = $Graphics/PlayerChecker
@onready var floor_checker: RayCast2D = $Graphics/FloorChecker
@onready var calm_down_timer: Timer = $CalmDownTimer

# 用于处理 敌人 可以无视地形障碍物看见 玩家 的问题
func can_see_player() -> bool:
	if not player_checker.is_colliding():
		return false
	
	# BUG: 部分版本中 返回的 null 值无法转换为 bool 值, 需要手动转换
	# return player_checker.get_collider() is Player
	
	if player_checker.get_collider() is Player:
		return true
	return false

func tick_physics(state: State, delta: float) -> void:
	match state:
		State.IDLE:
			move(0.0, delta)
		
		State.WALK:
			move(max_speed / 3, delta)
			
		State.RUN:
			if wall_checker.is_colliding() or not floor_checker.is_colliding():
				direction *= -1
			move(max_speed, delta)
			if can_see_player():
				calm_down_timer.start()
			

func get_next_state(state: State) -> State:
	if can_see_player():
		return State.RUN
		
	match state:
		State.IDLE:
			if state_machin.state_time >2:
				return State.WALK
		
		State.WALK:
			if wall_checker.is_colliding() or not floor_checker.is_colliding():
				return State.IDLE
		
		State.RUN:
			if calm_down_timer.is_stopped():
				return State.WALK
	
	return state
	
	
func transition_state(from: State, to: State) -> void:
	print("<Enemy.Boar> [%s] %s => %s" % [
		Engine.get_physics_frames(),
		State.keys()[from] if from != 1 else "<START>",
		State.keys()[to],		
	])
	
	match to:
		State.IDLE:
			animation_player.play("idle")
			if wall_checker.is_colliding():
				direction *= -1
		
		State.WALK:
			animation_player.play("walk")
			if not floor_checker.is_colliding():
				direction *= -1
				floor_checker.force_raycast_update()
			
		State.RUN:
			animation_player.play("run")
		
			


func _on_hurtbox_hurt(hitbox: Hitbox) -> void:
	pass # Replace with function body.
