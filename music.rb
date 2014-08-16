require 'dl/import'

if RUBY_PLATFORM.include?('x86_64-cygwin')
	class LiveMIDI
		#windows code will go here
		ON = 0x90
		OFF = 0x80
		PC = 0xC0

		def initialize
			open
		end

		def note_on(channel, note, velocity=64)
			message(ON | channel, note, velocity)   #sending the three parameters as required by the note_on functionality

			#need to figure out how to make the pointers work 
		end

		def note_off(channel, note, velocity=64)
			message(OFF | channel, note, velocity)
		end

		def program_change(channel, preset)
			message(PC | channel, preset)
		end



		module C
			extend DL::Importer
			dlload 'winmm'

			extern "int midiOutOpen(HMIDIOUT*,int,int,int,int)"
			extern "int midiOutClose(int)"
			extern "int midiOutShortMsg(int,int)"
		end
		
		def open
			@device = DL.malloc(DL.sizeof('I'))
			C.midiOutOpen(@device, -1,0,0,0)
		end

		def close 
			C.midiOutClose(@device.ptr.to_i)
			p @device.ptr.to_i #message for debugging 
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

		module CF
			extend DL::Importer
			dlload '/System/Library/Framworks/CoreFoundation.framework/Versions/Current/CoreFoundation'

			extern "void * CFStringCreateWithCString (void *, char *, int)"
		end



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

