###########################################################
# This experiment presents pictures of faces with different
# expression. The aim is to study emotional contagion in 
# the context of sleep deprivation. 
# The paradigm is adapted from Wright et al, Neuroimage
# 42 (2008) 956-968.
#
# By Gustav Nilsonne 121128
# Free to use with attribution.
###########################################################

scenario = "FACES_sce";
scenario_type = fMRI;
pulses_per_scan = 1;
pulse_code = 115;
response_logging = log_active; # Log only if response is expected
response_matching = simple_matching;

default_output_port = 1; #parallel port 
response_port_output = false;
write_codes = true;
pulse_width = 100;

#default_max_responses = 1;
default_all_responses = true;
active_buttons = 5;
button_codes = 1, 2, 3, 4, 5;

default_background_color = 100, 100, 100;  # Gray
default_font = "Verdana";      
default_font_size = 30;  

#######################################
begin;
#######################################

# READ TEMPLATE WITH LIST OF PICTURES #
TEMPLATE "FACES_tem.tem";
picture {} default;

# FIXATION CROSS #
picture {text {caption = "+"; font_size=100; font_color = 255,255,255,;}; x=0;y=0;} fixation_cross;

# RANGE OF RATING SCALE # 
array { 
	text { caption = "0"; }; 
	text { caption = "100"; }; 
} number;

# RATING SCALE # 
text { caption = "Placeholder"; } question; # Depends on condition, will be specified in PCL

text { caption = "XXX"; font_size =20; preload = false; } gap; 

picture { 
box { height = 10; width = 200; color = 255, 255, 255; }; 
x = 0; y = 0; 
box { height = 50; width = 5; color = 255, 255, 255; }; 
x = 0; y = 0; 
text gap; 
x = -200; y = 0; 
text gap; 
x = 200; y = 0; 
text gap; 
x=0; y=150; 
box { height = 600; width = 100; color = 100, 100, 100; } box1; 
x = -350; y = 0;
box { height = 600; width = 100; color = 100, 100, 100; } box2; 
x = 350; y = 0; 
box { height = 100; width = 800; color = 100, 100, 100; } box3; 
x = 0; y = -250; 
box { height = 100; width = 800; color = 100, 100, 100; } box4; 
x = 0; y = 250; 
} scale; 

# WAKE-UP BOX #
picture {
box { height = 600; width = 100; color = 255, 60, 60; } box5; 
x = -350; y = 0;
box { height = 600; width = 100; color = 255, 60, 60; } box6; 
x = 350; y = 0; 
box { height = 100; width = 800; color = 255, 60, 60; } box7; 
x = 0; y = -250; 
box { height = 100; width = 800; color = 255, 60, 60; } box8; 
x = 0; y = 250; 
} wakeup;

# DEFINE TRIALS #
# Port Output
trial{
   trial_duration = stimuli_length;
   trial_type = fixed;
	all_responses = false;
	
	stimulus_event{
		nothing {};
      port_code = 99;
      code = "port_output";
      } ev_port_output;
}tr_port_output;

# Stimulus Presentation
trial {     
   trial_duration = stimuli_length;
   trial_type = fixed;
	all_responses = false;
   stimulus_event {  # Target
		picture {
			text { caption = "Pic"; }; x = 0; y = 0;
      } pic_pic2;  
		time = 0;
		duration = 500;
      code = "Pic";
   } ev_pic2;
   stimulus_event {  # Fixation cross
      picture default;  
		time = 500;
		duration = 500;
      code = "Blank";
   } ev_blank;
}tr_pic;

# Response
trial {
	all_responses = true;	
	stimulus_event{
		picture {
		} pic_rate; 
		time=0;
		code = "Rating";
	}ev_rate;
} tr_rate;

# Intertrial fixation cross
trial {     
   trial_duration = stimuli_length;
   trial_type = fixed;
	all_responses = false;
	stimulus_event{
      picture fixation_cross;
		time = 0;		
		duration = 10000;
      code = "ITI";
   } ev_iti; 
}tr_iti;  

# Rest
trial {     
   trial_duration = stimuli_length;
   trial_type = fixed;
	all_responses = false;
	stimulus_event{  
      picture {
         text { caption = "PAUS"; font_size=100; }; x = 0; y = 0;
         } pic_rest;
		time = 0;   
		duration = 15000;
		code = "Rest";
   } ev_rest;     
}tr_rest;  

#######################################
begin_pcl;
#######################################

default.present();
parameter_window.remove_all();
output_port arrington = output_port_manager.get_port(2);

int pulse_neutral = 2;
int pulse_happy = 4;
int pulse_angry = 8;

# READ TRIAL LIST #
# When program is run, enter name of trial list
string enterfname = logfile.subject();
string fname = "triallist_" + enterfname + ".txt";

# LOCATE TRIALS #
# Loop over blocks
int ntmax = 120; # Number of trials
array<int> alltrials[ntmax][3]; # Size of trial list
input_file myfile = new input_file;
myfile.open(fname);
loop int r = 1; until r > ntmax begin
	alltrials[r][1] = myfile.get_int();
	alltrials[r][2] = myfile.get_int(); 
	alltrials[r][3] = myfile.get_int(); 
	r=r+1;
end;
myfile.close();

# CREATE OUTPUT FILE #
output_file resfile = new output_file;
resfile.open("FACES_log.txt", false);
resfile.print("Block_type");
resfile.print("\t");
resfile.print("Question_type");
resfile.print("\t");
resfile.print("Rating");
resfile.print("\t");
resfile.print("Response_time");
resfile.print("\n");

string blockcond = "null"; # For logging block type, will be redefined below

# Get fMRI trigger pulse
int pulses=pulse_manager.main_pulse_count();
loop until (pulse_manager.main_pulse_count() > pulses)
begin
end;

# Start the eye-tracker
arrington.send_code(21);

# RUN TRIALS #
# Loop over two presentations of the paradigm
loop int pres = 1; until pres > 2 begin
	if (pres == 2) then
		tr_rest.present();
	end;

# Present a 10 s fixation cross
tr_iti.present();

# Loop over blocks
loop int bl = 1; until bl > 3 begin
		
# Loop over trials
	loop int tr = 1; until tr > 20 begin
		
# Get picture and load it into trial
		int trialno = (bl-1)*20 + tr;
		string thiscond = string(alltrials[trialno][2]);
		int thispic = alltrials[trialno][3];
		pic_pic2.clear();		
		pic_pic2.add_part(pic[thispic],0,0);
		ev_pic2.set_event_code("Pic2");
		tr = tr+1;
			
# Present trial
		if (thiscond == "1") then
			ev_pic2.set_event_code("neutral");
			ev_port_output.set_port_code(pulse_neutral);
		elseif (thiscond == "2") then
			ev_pic2.set_event_code("happy");
			ev_port_output.set_port_code(pulse_happy);
			blockcond = "Happy";
		elseif (thiscond == "3") then
			ev_pic2.set_event_code("angry");
			ev_port_output.set_port_code(pulse_angry);
			blockcond = "Angry";
		end;		
		tr_port_output.present();
		tr_pic.present();
		
	end;
		
# Present fixation cross between blocks
	tr_iti.present();
	bl = bl+1;
end;

# AFTER SESSION, GET RATING
# Loop over questions
	int questiontype = 1;
	loop questiontype = 1; until questiontype > 2 begin
		if (questiontype == 1) then
			question.set_caption("Hur glad känner du dig?");
		elseif (questiontype == 2) then
			question.set_caption("Hur arg känner du dig?");
		end;
question.redraw();
tr_rate.present();
questiontype = questiontype + 1;
	int starttime = clock.time(); # Use this to determine when to put in wake-up signal
	
	loop 
		int left = response_manager.total_response_count(1);	
		int right = response_manager.total_response_count(2); 	
		int confirm = response_manager.total_response_count(3); 
		int left_up = response_manager.total_response_count(4); 
		int right_up = response_manager.total_response_count(5);
		int x = 0; 
		int x_inc = 2; 
		int movement = 0;
		scale.set_part(3, number[1]); 
		scale.set_part(4, number[2]); 
		scale.set_part(5, question); 
		scale.set_part(6, box1); 
		scale.set_part(7, box2); 
		scale.set_part(8, box3); 
		scale.set_part(9, box4); 
		scale.present(); 
	until 
		response_manager.total_response_count(3) > confirm 
	begin 
		if response_manager.total_response_count( 1 ) > left then 
			movement = -1;
			left = response_manager.total_response_count( 1 );
		elseif response_manager.total_response_count( 4 ) > left_up then 
			movement = 0;
			left_up = response_manager.total_response_count( 4 ); 
		elseif response_manager.total_response_count( 2 ) > right then 
			movement = 1;
			right = response_manager.total_response_count( 2 );
		elseif response_manager.total_response_count( 5 ) > right_up then 
			movement = 0;
			right_up = response_manager.total_response_count( 5 );	
	end; 
	x = x + (movement * x_inc); 
		if x < -100 then 
			x = -100 
		elseif x > 100 then 
			x = 100 
		end;
		
	scale.set_part_x(2, x); 
	scale.present(); 
	int trialtime = clock.time() - starttime;
		if trialtime > 10000 then
			scale.set_part(6, box5);
			scale.set_part(7, box6);
			scale.set_part(8, box7);
			scale.set_part(9, box8);
		end;		
		if response_manager.total_response_count(3) > confirm then
			
			# Log response characteristics
			resfile.print(blockcond);
			resfile.print("\t");
			resfile.print(questiontype);
			resfile.print("\t");
			resfile.print((x+100)/2); 
			resfile.print("\t");
			resfile.print(trialtime); 
			resfile.print("\n");
		end;
	end;	
	end;
	
# DO IT ALL AGAIN FOR THE NEXT CONDITION #
# Start with a 10 s fixation cross
tr_iti.present();

# Loop over blocks
loop int bl = 4; until bl > 6 begin
		
# Loop over trials
	loop int tr = 1; until tr > 20 begin
		
# Get picture and load it into trial
		int trialno = (bl-1)*20 + tr;
		string thiscond = string(alltrials[trialno][2]);
		if (thiscond == "2") then
			question.set_caption("Hur glad känner du dig?");
			blockcond = "Happy";
		elseif (thiscond == "3") then
			question.set_caption("Hur arg känner du dig?");
			blockcond = "Angry";
		end;
		int thispic = alltrials[trialno][3];
		pic_pic2.clear();		
		pic_pic2.add_part(pic[thispic],0,0);
		ev_pic2.set_event_code("Pic2");
		tr = tr+1;
			
# Present trial
		if (thiscond == "1") then
			ev_pic2.set_event_code("neutral");
			ev_port_output.set_port_code(pulse_neutral)
		elseif (thiscond == "2") then
			ev_pic2.set_event_code("happy");
			ev_port_output.set_port_code(pulse_happy)
		elseif (thiscond == "3") then
			ev_pic2.set_event_code("angry");
			ev_port_output.set_port_code(pulse_angry)
		end;		
		tr_port_output.present();		
		tr_pic.present();
	end;
		
# Present fixation cross between blocks
	tr_iti.present();
	bl = bl+1;
end;

# AFTER SESSION, GET RATING
# Loop over questions
	questiontype = 1;
	loop questiontype = 1; until questiontype > 2 begin
		if (questiontype == 1) then
			question.set_caption("Hur glad känner du dig?");
		elseif (questiontype == 2) then
			question.set_caption("Hur arg känner du dig?");
		end;
question.redraw();
tr_rate.present();
questiontype = questiontype + 1;
	int starttime = clock.time(); # Use this to determine when to put in wake-up signal
	
	loop 
		int left = response_manager.total_response_count(1);	
		int right = response_manager.total_response_count(2); 	
		int confirm = response_manager.total_response_count(3); 
		int left_up = response_manager.total_response_count(4); 
		int right_up = response_manager.total_response_count(5);
		int x = 0; 
		int x_inc = 2; 
		int movement = 0;
		scale.set_part(3, number[1]); 
		scale.set_part(4, number[2]); 
		scale.set_part(5, question); 
		scale.set_part(6, box1); 
		scale.set_part(7, box2); 
		scale.set_part(8, box3); 
		scale.set_part(9, box4); 
		scale.present(); 
	until 
		response_manager.total_response_count(3) > confirm 
	begin 
		if response_manager.total_response_count( 1 ) > left then 
			movement = -1;
			left = response_manager.total_response_count( 1 );
		elseif response_manager.total_response_count( 4 ) > left_up then 
			movement = 0;
			left_up = response_manager.total_response_count( 4 ); 
		elseif response_manager.total_response_count( 2 ) > right then 
			movement = 1;
			right = response_manager.total_response_count( 2 );
		elseif response_manager.total_response_count( 5 ) > right_up then 
			movement = 0;
			right_up = response_manager.total_response_count( 5 );	
		end; 
	x = x + (movement * x_inc); 
		if x < -100 then 
			x = -100 
		elseif x > 100 then 
			x = 100 
		end;
		
	scale.set_part_x(2, x); 
	scale.present(); 
	int trialtime = clock.time() - starttime;
		if trialtime > 10000 then
			scale.set_part(6, box5);
			scale.set_part(7, box6);
			scale.set_part(8, box7);
			scale.set_part(9, box8);
		end;		
		if response_manager.total_response_count(3) > confirm then
			
			# Log response characteristics
			resfile.print(blockcond);
			resfile.print("\t");
			resfile.print(questiontype);
			resfile.print("\t");
			resfile.print((x+100)/2); 
			resfile.print("\t");
			resfile.print(trialtime); 
			resfile.print("\n");
		end;
	end;	
	end;
	
	pres = pres+1;
end;

# Stop the eye-tracker
arrington.send_code(23);