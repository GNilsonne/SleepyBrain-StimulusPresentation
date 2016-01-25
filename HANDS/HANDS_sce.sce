#########################################################
# This experiment presents pictures of hands being pain 
# stimulated and control pictures with no pain. The aim
# is to study empathy in the context of sleep deprivation. 
#
# By Gustav Nilsonne 121103
# Free to use with attribution.
#########################################################

scenario = "HANDS_sce";
scenario_type = fMRI;
pulses_per_scan = 1;
pulse_code = 115;
response_logging = log_active; # Log only if response is expected
response_matching = simple_matching;

default_max_responses = 1;
default_all_responses = false;
active_buttons = 5;
button_codes = 1, 2, 3, 4, 5;

default_background_color = 100, 100, 100;  # Gray
default_font = "Verdana";      
default_font_size = 30;                                 

#######################################
begin;
#######################################

# READ TEMPLATE WITH LIST OF PICTURES #
TEMPLATE "HANDS_tem.tem";
picture {} default;

# FIXATION CROSS #
picture {text {caption = "+"; font_size=100; font_color = 255,255,255,;}; x=0;y=0;} fixation_cross;

# RANGE OF RATING SCALE # 
array { 
	text { caption = "0"; }; 
	text { caption = "100"; }; 
} number;

# RATING SCALE # 
text { caption = "Skatta ditt upplevda obehag"; } question; # Rate your unpleasantness

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

# Stimulus presentation
trial {     
   trial_duration = stimuli_length;
   trial_type = fixed;
	all_responses = false;
   stimulus_event {  # Target
		picture {
			text { caption = "Pic"; }; x = 0; y = 0;
      } pic_pic2;  
		time = 0;
		duration = 3500;
      code = "Pic";
      # port_code = 99; # To be used in the scanner
   } ev_pic2;
   stimulus_event {  # Blank screen
      picture {
         } pic_blank;  
		time = 3500;
		duration = 2000;
      code = "Blank";
      # port_code = 99; # To be used in the scanner
   } ev_blank;
}tr_pic;

# Response
trial {
	all_responses = true;	
	stimulus_event{
		picture {
		} pic_rate; 
		time=0;
		code = "Rate";
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
		duration = 4000;
      code = "ITI";
   } ev_iti; 
}tr_iti;  

#######################################
begin_pcl;
#######################################

default.present();
parameter_window.remove_all();
output_port arrington = output_port_manager.get_port(2);

# READ TRIAL LIST #
# When program is run, enter "1" to "4" to choose trial list
string enterfname = logfile.subject();
string fname = "triallist_" + enterfname + ".txt";

# LOCATE TRIALS #
int ntmax = 40; # Number of trials
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
resfile.open("HANDS_log.txt", false);
resfile.print("Condition");
resfile.print("\t");
resfile.print("Picture_no.");
resfile.print("\t");
resfile.print("Rating_Origin");
resfile.print("\t");
resfile.print("Rated_Unpleasantness");
resfile.print("\t");
resfile.print("Last_Response_Time_(ms)");
resfile.print("\n");

# Get fMRI trigger pulse
int pulses=pulse_manager.main_pulse_count();
loop until (pulse_manager.main_pulse_count() > pulses)
begin
end;

# Start the eye-tracker
arrington.send_code(21);

# DEFINE POSITIONS WHERE RATING CURSOR MAY APPEAR # 
array<int>cursor_startpoints[20] = { -100, -100, -80, -80, -60, -60, -40, -40, -20, -20, 20, 20 , 40, 40 , 60, 60, 80, 80, 100, 100 };

# RUN TRIALS #
# Loop over first half of stimuli
cursor_startpoints.shuffle();
loop int tr = 1; until tr > 20 begin

# Get picture and load it into trial
	int thiscond = alltrials[tr][2];
	int thispic = alltrials[tr][3];
	pic_pic2.clear();		
	pic_pic2.add_part(pic[thispic],0,0);
	ev_pic2.set_event_code("Pic2");

# Present fixation cross
	ev_iti.set_event_code("ITI");
	ev_iti.set_duration(random(4000, 6000)); 
	tr_iti.present();
	
# Present stimulus and record response
	tr_pic.present();
	tr_rate.present();
	int starttime = clock.time(); # Use this to determine when to put in wake-up signal
	
	loop 
		int left = response_manager.total_response_count(1);	
		int right = response_manager.total_response_count(2); 	
		int confirm = response_manager.total_response_count(3); 
		int left_up = response_manager.total_response_count(4); 
		int right_up = response_manager.total_response_count(5);
		int x = cursor_startpoints[tr]; 
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
			if alltrials[tr][3] <= 20 then
				resfile.print("Pain");
			elseif alltrials[tr][3] >= 21 then
				resfile.print("No_Pain");
			end;
			
			# Find response time
			stimulus_data last_stim = stimulus_manager.last_stimulus_data();
			int onset = last_stim.time();
			response_data last_response = response_manager.last_response_data();
			int resp = last_response.time();
			int resp_time = resp - onset - 500; # Must remove 500 ms to get correct time as indicated in automatic log file
			
			# Log response characteristics
			resfile.print("\t");
			resfile.print(string(thispic));			
			resfile.print("\t");
			resfile.print(cursor_startpoints[tr]);
			resfile.print("\t");
			resfile.print((x+100)/2); 
			resfile.print("\t");
			resfile.print(string(resp_time));
			resfile.print("\n");
		end;
	end;	
	tr=tr+1;
end;

# TAKE A BREAK AFTER HALF THE STIMULI #
tr_rest.present();

# CONTINUE AGAIN #
# Loop over second half of stimuli
cursor_startpoints.shuffle();
loop int tr = 21; until tr > 40 begin

# Get picture and load it into trial
	int thiscond = alltrials[tr][2];
	int thispic = alltrials[tr][3];
	pic_pic2.clear();		
	pic_pic2.add_part(pic[thispic],0,0);
	ev_pic2.set_event_code("Pic2");

# Present fixation cross
	ev_iti.set_event_code("ITI");
	ev_iti.set_duration(random(4000, 6000)); 
	tr_iti.present();
	
# Present stimulus and record response
	tr_pic.present();
	tr_rate.present();
	int starttime = clock.time(); # Use this to determine when to put in wake-up signal
	
	loop 
		int left = response_manager.total_response_count(1);	
		int right = response_manager.total_response_count(2); 	
		int confirm = response_manager.total_response_count(3); 
		int left_up = response_manager.total_response_count(4); 
		int right_up = response_manager.total_response_count(5);
		int x = random (-100, 100); 
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
			if alltrials[tr][3] <= 20 then
				resfile.print("Pain");
			elseif alltrials[tr][3] >= 21 then
				resfile.print("No_Pain");
			end;
			
			# Find response time
			stimulus_data last_stim = stimulus_manager.last_stimulus_data();
			int onset = last_stim.time();
			response_data last_response = response_manager.last_response_data();
			int resp = last_response.time();
			int resp_time = resp - onset - 500; # Must remove 500 ms to get correct time as indicated in automatic log file
			
			# Log response characteristics
			resfile.print("\t");
			resfile.print(string(thispic));			
			resfile.print("\t");
			resfile.print(cursor_startpoints[tr-20]);
			resfile.print("\t");
			resfile.print((x+100)/2); 
			resfile.print("\t");
			resfile.print(string(resp_time));
			resfile.print("\n");
		end;
	end;
	tr=tr+1;
end;

# Close results file	
resfile.close();

# Stop the eye-tracker
arrington.send_code(23);