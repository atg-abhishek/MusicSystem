require 'dl/import'

class LiveMIDI
	ON = 0x90
	OFF = 0x80
	PC = 0xC0

	def initialize
		open
	end

	def note_on(channel, note, velocity=64)
		message(ON | channel, note, velocity)   #sending the three parameters as required by the note_on functionality
	end

	def note_off(channel, note, velocity=64)
		message(OFF | channel, note, velocity)
	end

	def program_change(channel, preset)
		message(PC | channel, preset)
	end

end

if RUBY_PLATFORM.include?('x86_64-cygwin')
	class LiveMIDI
		#windows code will go here
		module C
			extend DL::Importer
			dlload 'winmm'

			extern "int midiOutOpen(HMIDIOUT*,int,int,int,int)"
			extern "int midiOutClose(int)"
			extern "int midiOutShortMsg(int,int)"
		end
		
		def open
			@device = DL.malloc(4)
			C.midiOutOpen(@device, -1,0,0,0)
		end

		def close 
			C.midiOutClose(@device.ptr.to_i)
			p @device.ptr.to_i
		end

		def message(one, two=0, three=0)
			message = one + (two<<8) + (three<<16)
			C.midiOutShortMsg(@device.ptr, message)
		end
		
		midi = LiveMIDI.new
		midi.note_on(0,60,100)
		sleep(1)
		midi.note_off(0,60)
		sleep(1)
		midi.program_change(1,40)
		midi.note_on(1,60,100)
		sleep(1)
		midi.note_off(1,60)

	end
elsif RUBY_PLATFORM.include?('darwin')
	class LiveMIDI
		#mac code will go here
	end
elsif RUBY_PLATFORM.include?('linux')
	class LiveMIDI
		#linux code will go here
	end
else
	raise "Couldn't find a LiveMIDI implementation for your platform"
end

