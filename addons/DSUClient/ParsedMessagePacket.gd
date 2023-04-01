class_name ParsedMessagePacket

var magic_string: String
var protocol_version: int
var packet_length: int
var checksum: int
var client_id: int
var type: int
var packet: PackedByteArray

enum {
	VERSION_INFO = 1048576,
	CONTROLLER_INFO = 1048577,
	CONTROLLER_DATA = 1048578
}

func _init(packet):
	self.magic_string = packet.slice(0, 4).get_string_from_utf8()
	self.protocol_version = packet.decode_u16(4)
	self.packet_length = packet.decode_u16(6)
	self.checksum = packet.decode_u32(8)
	self.client_id = packet.decode_u32(12)
	self.type = packet.decode_u32(16)
	self.packet = packet.slice(20)
