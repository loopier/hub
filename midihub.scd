//---------------------------------------------- HUB - OSC
(
// ----------------------------
// ----    START SERVER    ----
// ----------------------------
Server.default = Server.internal;
s = Server.default;
s.boot
)

(
// -----------------------
// ---- PER CONNECTAR ----
// -----------------------
//var ip="127.0.0.1";
// var ip="192.168.1.151";    // alex
var ip = "10.7.220.209";
// var ip="192.168.1.154";    // alvaro
var portOut=2006;
n = NetAddr(ip, portOut);
)


(
// ---------------------------
// ---- PER DEFINIR ACCIO ----
// ---------------------------
var address = "/blo/hub/ext/gest";
var portIn = 3006;

OSCdef(\hub,{|msg, time, addr, recvPort|
	var inlet = msg[1];
	var value = msg[2];
	msg.postln;

},"/blo/hub/ext/gest",recvPort:portIn);
)

(
// -----------------------
// ---- ENVIO TRIGGER ----
// -----------------------
n.sendMsg("/blo/hub/ext/gest",0,0);
OSCdef(\hub).enable;
)

//---------------------------------------------- MIDI
MIDIClient.init
MIDIClient.destinations
MIDIIn.connectAll;

// m = MIDIOut.newByName("Scarlett 2i4 USB", "Scarlett 2i4 USB")
m = MIDIOut.newByName("USB MIDI Device", "USB MIDI Device"); // victor cable

// test
m.noteOn(0, 60, 127);
m.noteOff(0, 60, 0);

// panic
m.allNotesOff(0)
(
// MIDI to OSC
MIDIFunc.cc({arg ...args;
	args.postln;
	// args[0].postln;
	n.sendMsg("/blo/hub/ext/gest",0, args[0].linlin(0, 127, 0.0, 1.0));
});

)

(
// OSC to MIDI
var address = "/blo/hub/ext/gest";
var portIn = 3006;

OSCdef(\hub,{|msg, time, addr, recvPort|
	var inlet1 = msg[1].linlin(0.0, 1.0, 30, 94);
	var inlet2 = msg[2];
	var value = inlet1 + ([7,12].choose * inlet2);
	// msg.postln;
	value.postln;
	~playnote.next(value);
	~playnote.reset;

},"/blo/hub/ext/gest",recvPort:portIn);
)

(
// ---------------------------
// ---- PER DEFINIR ACCIO ----
// ---------------------------
~playnote = Routine({|inval,inval2|
	m.noteOn(0, inval, 127);
	// inval.postln;
	// 0.5.wait;
	m.noteOff(0, inval, 127);
	// "off".postln;
});
)

// test routine
(
~playnote.next(60);
~playnote.reset;
)




(
// --------------------
// ----    EXIT    ----
// ---- At the end ----
// --------------------
b.clear;
x.free;
s.quit;
OSCdef(\hub).disable;
OSCdef(\hub).clear;
n.disconect;
)
