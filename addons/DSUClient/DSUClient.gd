extends Node
class_name DSUClient

var udp := PacketPeerUDP.new()
var keep_alive_message: PackedByteArray = RequestPacketBuilder.new().subscribe(0).bytes

var controllers = Array()
var keep_alive_timer = Timer.new()

func start_polling():
	keep_alive_timer.start()
func stop_polling():
	keep_alive_timer.stop()

func _init():
	keep_alive_timer.timeout.connect(keep_alive)
	add_child(keep_alive_timer)
	udp.connect_to_host("127.0.0.1", 26760)
	for i in range(0, 256):
		controllers.append(DSUController.new(i))

func keep_alive():
	udp.put_packet(keep_alive_message)

func _process(delta):
	for c in controllers:
		c.axes.gyroscope = Vector3()
		c.ticks = 0
	while udp.get_available_packet_count() > 0:
		var packet = udp.get_packet()
		var message = ParsedMessagePacket.new(packet)
		
		if message.type == ParsedMessagePacket.CONTROLLER_DATA:
			# Apply controler data to "controllers"
			var controller = controllers[message.packet.decode_u8(0)]
			
			controller.state = message.packet.decode_u8(1)
			controller.model = message.packet.decode_u8(2)
			controller.connection_type = message.packet.decode_u8(3)
			controller.battery_status = message.packet.decode_u8(10)
			
			var bitmap1 = message.packet[16]
			var bitmap2 = message.packet[17]
			
			
			controller.buttons.minus = bool(bitmap1 & 0b00000001)
			controller.buttons.l3 = bool(bitmap1 & 0b00000010)
			controller.buttons.r3 = bool(bitmap1 & 0b00000100)
			controller.buttons.plus = bool(bitmap1 & 0b00001000)
			controller.buttons.dpad_up = bool(bitmap1 & 0b00010000)
			controller.buttons.dpad_right = bool(bitmap1 & 0b00100000)
			controller.buttons.dpad_down = bool(bitmap1 & 0b01000000)
			controller.buttons.dpad_left = bool(bitmap1 & 0b10000000)
			
			controller.buttons.l2 = bool(bitmap2 & 0b00000001)
			controller.buttons.r2 = bool(bitmap2 & 0b00000010)
			controller.buttons.l1 = bool(bitmap2 & 0b00000100)
			controller.buttons.r1 = bool(bitmap2 & 0b00001000)
			controller.buttons.x = bool(bitmap2 & 0b00010000)
			controller.buttons.a = bool(bitmap2 & 0b00100000)
			controller.buttons.b = bool(bitmap2 & 0b01000000)
			controller.buttons.y = bool(bitmap2 & 0b10000000)
			
			controller.buttons.home = bool(message.packet[18])
			controller.buttons.touch = bool(message.packet[19])
			
			controller.axes.left_stick.x = message.packet.decode_s8(20)
			controller.axes.left_stick.y = message.packet.decode_s8(21)
			controller.axes.right_stick.x = message.packet.decode_s8(22)
			controller.axes.right_stick.y = message.packet.decode_s8(23)
			
			controller.axes.accelerometer = Vector3(
				message.packet.decode_float(56),
				message.packet.decode_float(60),
				message.packet.decode_float(64))
			controller.axes.gyroscope += Vector3(
				message.packet.decode_float(68),
				-message.packet.decode_float(72),
				-message.packet.decode_float(76))
			
# Everything below here is for basic rotation calculation
			controller.ticks += 1
			controller.timestamp = message.packet.decode_u64(48)
			if controller.previous_timestamp == 0:
				controller.previous_timestamp = controller.timestamp
	
	for c in controllers:
		if c.state == DSUController.STATES.CONNECTED:
			if c.axes.gyroscope.x: c.axes.gyroscope.x /= c.ticks
			if c.axes.gyroscope.x: c.axes.gyroscope.y /= c.ticks
			if c.axes.gyroscope.x: c.axes.gyroscope.z /= c.ticks
			c.calculate_fixed_rotation(c.axes.gyroscope, c.timestamp)
			
