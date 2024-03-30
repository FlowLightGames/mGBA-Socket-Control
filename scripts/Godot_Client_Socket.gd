extends Node
class_name GBA_Socket

var input_buffer:Array[int]=[0,0,0,0,0,0,0,0,0,0]

var sock:StreamPeerTCP=StreamPeerTCP.new()
# Called when the node enters the scene tree for the first time.

func _ready():
	#sock.big_endian=true
	sock.connect_to_host("127.0.0.1",8888)
	sock.poll()

func get_highest_index()->int:
	var counter=0
	var current_index=0
	for i in range(input_buffer.size()):
		if input_buffer[i]>counter:
			counter=input_buffer[i]
			current_index=i
	if counter>0:
		return current_index
	else :
		return -1

func reset_buffer():
	input_buffer=[0,0,0,0,0,0,0,0,0,0]

func _physics_process(delta):
	pass

#ASCII:
	#-:45
	#0:48
	#1:49
	#2:50
	#3:51
	#4:52
	#5:53
	#6:54
	#7:55
	#8:56
	#9:57

func _on_timer_timeout():
	sock.poll()
	#print(sock.get_status())
	if sock.get_status()==2:
		var index:int =get_highest_index()
		if index>-1:
			var data:PackedByteArray=[]
			data.append(index+48)
			sock.put_data(data)
			reset_buffer()
		#else:
			#var data:PackedByteArray=[]
			#data.append(45)
			#data.append(49)
			#sock.put_data(data)
			#reset_buffer()
		
		
