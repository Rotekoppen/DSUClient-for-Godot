class_name  DSUController

var slot: int
var connected: bool
var state: STATES
var model: MODELS
var connection_type: CONNECTION_TYPES
var battery_status: BATTERY_STATUSES
var timestamp = 0
var ticks = 0
var time_delta = 0

var buttons = DSUControllerButtons.new()
var axes = DSUControllerAxes.new()

enum STATES {
	DISCONNECTED,
	RESERVED,
	CONNECTED }

enum MODELS {
	UNKNOWN,
	PARTIAL_GYRO,
	NO_GYRO = 1,
	FULL_GYRO,
	VR } # i guess dont know what it really is

enum CONNECTION_TYPES {
	UNKNOWN,
	USB,
	BLUETOOTH }

enum BATTERY_STATUSES {
	UNKNOWN = 0x00,
	DYING = 0x01,
	LOW = 0x02,
	MEDIUM = 0x03,
	HIGH = 0x04,
	FULL = 0x05,
	CHARGING = 0xEE,
	CHARGED = 0xEF }

func _init(slot):
	self.slot = slot
	pass

func _to_string():
	return ("Controller : " +
		"slot=" + str(self.slot) + " " + 
		"state=" + str(self.state) + " " + 
		"model=" + str(self.model) + " " + 
		"connection_type=" + str(self.connection_type) + " " + 
		"battery_status=" + str(self.battery_status) + " " +
		"acceleration=" + str(self.axes.accelerometer) + " " +
		"rotation=" + str(self.rotation) + " "
	)

# Basic way to calculate the fixed rotation, but yeah this is a terrible way to do it and i dont really understand it
# If you do better please share
var rotation = Vector3()
var initial_orientation = Quaternion()
var accumulated_rotation = Quaternion()
var previous_timestamp = 0

func calculate_fixed_rotation(relative_rotation: Vector3, timestamp: int):
	var angular_velocity = relative_rotation * PI / 180.0 # Converts to radians
	var time_interval = (timestamp - self.previous_timestamp) / 1000000.0
	self.previous_timestamp = timestamp
	var axis = angular_velocity.normalized()
	var angle = angular_velocity.length() * time_interval

	if axis.is_normalized(): # Dont know why, but this prevents spewing errors
		var delta_rotation = Quaternion(axis, angle)
		self.accumulated_rotation = self.accumulated_rotation * delta_rotation
		var fixed_rotation = self.initial_orientation * self.accumulated_rotation
		self.rotation = fixed_rotation.get_euler()
