require 'dl/import'

class LiveMIDI
	ON = 0x90
	OFF = 0x80
	PC = 0xC0

def initialize
	open
end

