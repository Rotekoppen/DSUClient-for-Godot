class_name RequestPacketBuilder

var bytes: PackedByteArray = PackedByteArray()
func _init():
	pass

func crc32(data: PackedByteArray) -> int:
	var crc = 0xffffffff
	var size = data.size()
	for i in range(size):
		var byte = data[i]
		crc ^= byte
		for j in range(8):
			var mask = -(crc & 1)
			crc = (crc >> 1) ^ (0xedb88320 & mask)
	return crc ^ 0xffffffff

func append_header():
	# Magic String (DSUC for client)
	self.bytes.append_array([0x44, 0x53, 0x55, 0x43])
	# Protocol Version
	self.bytes.append_array([0xe9, 0x03])
	# Packet length
	self.bytes.append_array([0x00, 0x00])
	# CRC32 checksum
	self.bytes.append_array([0x00, 0x00, 0x00, 0x00])
	# Client ID (GDSU)
	self.bytes.append_array([0x47, 0x44, 0x53, 0x55])
	return self

func set_length(length):
	self.bytes.encode_u32(6, length)
	return self

func calculate_crc32():
	var checksum = self.crc32(self.bytes)
	self.bytes.encode_u32(8, checksum)
	return self

func get_protocol_version():
	# Append header
	self.append_header()
	# Message type
	self.bytes.append_array([0x00, 0x00, 0x10, 0x00])
	# Update message length and CRC
	self.set_length(4)
	self.calculate_crc32()
	return self

func get_controller_info(port_count, port_selection):
	# Append header
	self.append_header()
	# Message type
	self.bytes.append_array([0x01, 0x00, 0x10, 0x00])
	# Port count
	self.bytes.append_array([port_count, 0x00, 0x00, 0x00])
	# Port selection
	self.bytes.append_array(port_selection)
	# Update message length and CRC
	self.set_length(8)
	self.calculate_crc32()
	return self

func subscribe(mode, slot=0, mac_address=[0,0,0,0,0,0]):
	# Append header
	self.append_header()
	# Message type
	self.bytes.append_array([0x02, 0x00, 0x10, 0x00])
	# Mode and slot number
	self.bytes.append_array([mode, slot])
	# Mac Address
	self.bytes.append_array(mac_address)
	# Update message length and CRC
	self.set_length(12)
	self.calculate_crc32()
	return self
