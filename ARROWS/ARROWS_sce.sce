#########################################################
# This experiment presents IAPS pictures preceded by 
# instructions to upregulate or downregulate the 
# emotional response to the picture.
# This version of the script is for use in the behavioral
# lab and has no scanner sync.
#
# Adapted by Gustav Nilsonne 120625
# Original script by Armita Golkar
#########################################################

scenario = "ARROWS_sce";
scenario_type = fMRI;
pulses_per_scan = 1;
pulse_code = 115;
response_logging = log_active;  # Log only if response is expected
response_matching = simple_matching;

default_max_responses = 1;
default_all_responses = false;
active_buttons = 3;
button_codes = 1,2,3;

default_background_color = 100, 100, 100;  # Gray
default_font = "Verdana";      
default_font_size = 30;                                 

#######################################
begin;
#######################################

picture {} default;
picture {bitmap { filename = "instruction.jpg";}; x=0; y=0;} dummyinst;

# Read in pictures
TEMPLATE "ARROWS_tem.tem";

# DEFINE TRIALS #
# Instruction before experiment
trial {     
   trial_duration = stimuli_length;
   trial_type = fixed;
	all_responses = false;
      stimulus_event{  
      picture {
         bitmap {filename = "instruction.jpg"; width = 800; scale_factor = scale_to_width;}; x = 0; y = 0;
         } pic_dummyinst;
		time=0;
		duration = 10000;
      code = "Instruction";
      } ev_instruction;    
}tr_instruction;  

# Rest halfway through experiment
trial {     
   trial_duration = stimuli_length;
   trial_type = fixed;
	all_responses = false;
      stimulus_event{  
      picture {
         text { caption = "PAUS"; font_size=100; }; x = 0; y = 0;
         } pic_rest;
		time=0;   
		duration=15000;
		code = "Rest";
      } ev_rest;    
}tr_rest;  

# Regulation cue and stimulus picture
trial {     
   trial_duration = stimuli_length;
   trial_type = fixed;
	all_responses = false;
   stimulus_event{ 
      picture {
         text {caption = "Cue"; }; x = 0; y = 0;
         } pic_cue;  
		time = 0;
		duration = 2000; 
      code = "Cue";
      } ev_cue;
   stimulus_event{ 
      picture {
         text {caption = "Pic2";}; x = 0; y = 0;
         } pic_pic;  
         deltat = 2000;
		duration = 5000; 
      code = "Pic";
      port_code = 99;
      } ev_pic;
   stimulus_event {  # Blank screen
      picture {
         } pic_blank;  
		time = 7000;
		duration = 2000;
      code = "Blank";
   } ev_blank;
}tr_instpic;

# Response
trial {
	all_responses = true;	
	stimulus_event{
	picture {
		} pic_resp; 
		time = 0;
		code = "Response";
		}ev_resp;
} tr_resp;

# Intertrial interval (fixation crosss)
trial {     
   trial_duration = stimuli_length;
   trial_type = fixed;
	all_responses = false;
      stimulus_event{
			picture {
				text {caption = "+"; font_size=100; font_color = 255,255,255,;}; x=0;y=0;
			} pic_iti; 
		time = 0;		
		duration = 4000; # Will be randomised in PCL
      code = "ITI";
      } ev_iti;      
}tr_iti;  

###############################
begin_pcl;
###############################

default.present();
parameter_window.remove_all();
output_port arrington = output_port_manager.get_port(2);

# READ TRIAL LIST #
# When program is run, enter "1" to "6" to choose trial list
string enterfname = logfile.subject();
string fname = "triallist_" + enterfname + ".txt";

# LOCATE TRIALS #
int ntmax = 60; # Number of trials
array<int> alltrials[ntmax][5]; # Size of trial list
input_file myfile = new input_file;
myfile.open(fname);
loop int r=1; until r > ntmax begin
	alltrials[r][1] = myfile.get_int();
	alltrials[r][2] = myfile.get_int(); 
	alltrials[r][3] = myfile.get_int(); 
	alltrials[r][4] = myfile.get_int();
	alltrials[r][5] = myfile.get_int();
	r=r+1;
end;
myfile.close();

# CREATE OUTPUT FILE #
output_file resfile = new output_file;
resfile.open("ARROWS_log.txt", false);
resfile.print("Cue");
resfile.print("\t");
resfile.print("StimulusType");
resfile.print("\t");
resfile.print("RatedSuccessOfRegulation");
resfile.print("\n");

# Get fMRI trigger pulse
int pulses=pulse_manager.main_pulse_count();
loop until (pulse_manager.main_pulse_count() > pulses)
begin
end;

# Start the eye-tracker
arrington.send_code(21);

# RUN TRIALS #
# Show instructions
tr_instruction.present();

# Loop over first half of stimuli
loop int tr=1; until tr > 30 begin

	int thispic = alltrials[tr][2];
	int thiscond = alltrials[tr][3];
	int thisiti= alltrials[tr][5];
	
	pic_pic.clear();	
	pic_cue.clear();	
	
	pic_pic.add_part(pic[thispic],0,0);
	# ev_pic.set_event_code("pic");
	# ev_pic.set_port_code(pulse_pic);
	
	if thiscond == 1 then # Maintain neg 
		pic_cue.add_part(cue[1],0,0);
		pic_pic.add_part(pic[thispic],0,0);
		# ev_inst.set_event_code("Maintain");
		# ev_pic2.set_event_code("Pic2");
		# ev_pic2.set_port_code(pulse_pic2);

	elseif thiscond == 2 then # Upregulate
		pic_cue.add_part(cue[2],0,0);
		pic_pic.add_part(pic[thispic],0,0);
		# ev_inst.set_event_code("Enhance");
		# ev_pic2.set_event_code("Pic2");
		# ev_pic2.set_port_code(pulse_pic2);
	
	elseif thiscond == 3 then # Downregulate
		pic_cue.add_part(cue[3],0,0);
		pic_pic.add_part(pic[thispic],0,0);
		# ev_inst.set_event_code("Suppress");
		# ev_pic2.set_event_code("Pic2");
		# ev_pic2.set_port_code(pulse_pic2);
		
	elseif thiscond == 4 then # Maintain neutral
		pic_cue.add_part(cue[1],0,0);
		pic_pic.add_part(pic[thispic],0,0);
		# ev_inst.set_event_code("Maintain");
		# ev_pic2.set_event_code("Pic2");
		# ev_pic2.set_port_code(pulse_pic2);
	end;
	
# Show fixation cross
	ev_iti.set_event_code("ITI");
	ev_iti.set_duration(thisiti); 
	tr_iti.present();
	
# Show cue and stimulus
	tr_instpic.present();

# Get response
	int resp=0;
	int tnow= 0;
	int ttrial= 0;
	int tzero=0;
	int lo=1;
	int bpress=0;
	
	int confirm = response_manager.total_response_count(2); 
	int right = response_manager.total_response_count(3); 
	int left = response_manager.total_response_count(1);
	int movement = 0;	
	pic_resp.add_part(pic_skala[1],0,0);

loop
  	until 
		response_manager.total_response_count(2) > confirm 
	begin 
		if response_manager.total_response_count(1) > left then 
			movement = movement -1;
			left = response_manager.total_response_count(1);
			if movement >= 3 then
				movement = 3
			end;
			if movement <= -3 then
				movement = -3
			end;
			int sk = 5;
			if movement == 3 then
				sk= 8;
				elseif movement == 2 then
				sk= 7;
				elseif movement == 1 then
				sk= 6;
				elseif movement == 0 then
				sk= 5;
				elseif movement == -1 then
				sk= 4;
				elseif movement == -2 then
				sk= 3;
				elseif movement == -3 then
				sk= 2;
			end;
			lo=sk;
			pic_resp.clear();
			pic_resp.add_part(pic_skala[lo],0,0);

		elseif response_manager.total_response_count(3) > right then 
			movement = movement + 1;
			right = response_manager.total_response_count(3);	
			if movement >= 3 then
				movement = 3
			end;
			if movement <= -3 then
				movement = -3
			end;
			int sk = 5;
			if movement == 3 then
				sk= 8;
				elseif movement == 2 then
				sk= 7;
				elseif movement == 1 then
				sk= 6;
				elseif movement == 0 then
				sk= 5;
				elseif movement == -1 then
				sk= 4;
				elseif movement == -2 then
				sk= 3;
				elseif movement == -3 then
				sk= 2;
			end;
			lo=sk;
			pic_resp.clear();
			pic_resp.add_part(pic_skala[lo],0,0);
		end;
	if response_manager.total_response_count(2) > confirm then
	end;
		
	tr_resp.present();
	resp = lo-1;				
end;

resfile.print(thiscond);
resfile.print("\t");
resfile.print(thiscond);
resfile.print("\t");
resfile.print(resp);	
resfile.print("\n");

tr=tr+1;
	
end;

# Break after half the stimuli
tr_rest.present();

# Start again
loop int tr=31; until tr > 60 begin

	int thispic = alltrials[tr][2];
	int thiscond = alltrials[tr][3];
	int thisiti= alltrials[tr][5];
	
	pic_pic.clear();	
	pic_cue.clear();	
	
	pic_pic.add_part(pic[thispic],0,0);
	# ev_pic.set_event_code("pic");
	# ev_pic.set_port_code(pulse_pic);
	
	if thiscond == 1 then # Maintain neg 
		pic_cue.add_part(cue[1],0,0);
		pic_pic.add_part(pic[thispic],0,0);
		# ev_inst.set_event_code("Maintain");
		# ev_pic2.set_event_code("Pic2");
		# ev_pic2.set_port_code(pulse_pic2);

	elseif thiscond == 2 then # Upregulate
		pic_cue.add_part(cue[2],0,0);
		pic_pic.add_part(pic[thispic],0,0);
		# ev_inst.set_event_code("Enhance");
		# ev_pic2.set_event_code("Pic2");
		# ev_pic2.set_port_code(pulse_pic2);
	
	elseif thiscond == 3 then # Downregulate
		pic_cue.add_part(cue[3],0,0);
		pic_pic.add_part(pic[thispic],0,0);
		# ev_inst.set_event_code("Suppress");
		# ev_pic2.set_event_code("Pic2");
		# ev_pic2.set_port_code(pulse_pic2);
		
	elseif thiscond == 4 then # Maintain neutral
		pic_cue.add_part(cue[1],0,0);
		pic_pic.add_part(pic[thispic],0,0);
		# ev_inst.set_event_code("Maintain");
		# ev_pic2.set_event_code("Pic2");
		# ev_pic2.set_port_code(pulse_pic2);
	end;
	
# Show fixation cross
	ev_iti.set_event_code("ITI");
	ev_iti.set_duration(thisiti); 
	tr_iti.present();
	
# Show cue and stimulus
	tr_instpic.present();

# Get response
	int resp=0;
	int tnow= 0;
	int ttrial= 0;
	int tzero=0;
	int lo=1;
	int bpress=0;
	
	int confirm = response_manager.total_response_count( 2 ); 
	int right = response_manager.total_response_count( 3 ); 
	int left = response_manager.total_response_count( 1 );
	int movement = 0;	
	
	pic_resp.add_part(pic_skala[1],0,0);

loop
  	until 
		response_manager.total_response_count(2) > confirm 
	begin 
		if response_manager.total_response_count(1) > left then 
			movement = movement -1;
			left = response_manager.total_response_count(1);
			
			if movement >= 3 then
				movement = 3
			end;
			if movement <= -3 then
				movement = -3
			end;
			
			int sk = 5;
			if movement == 3 then
				sk= 8;
				elseif movement == 2 then
				sk= 7;
				elseif movement == 1 then
				sk= 6;
				elseif movement == 0 then
				sk= 5;
				elseif movement == -1 then
				sk= 4;
				elseif movement == -2 then
				sk= 3;
				elseif movement == -3 then
				sk= 2;
			end;

			lo=sk;
			pic_resp.clear();
			pic_resp.add_part(pic_skala[lo],0,0);
			
			
		elseif response_manager.total_response_count(3) > right then 
			movement = movement + 1;
			right = response_manager.total_response_count(3);	
 
			if movement >= 3 then
				movement = 3
			end;
			if movement <= -3 then
				movement = -3
			end;

			int sk= 5;
			if movement == 3 then
				sk= 8;
				elseif movement == 2 then
				sk= 7;
				elseif movement == 1 then
				sk= 6;
				elseif movement == 0 then
				sk= 5;
				elseif movement == -1 then
				sk= 4;
				elseif movement == -2 then
				sk= 3;
				elseif movement == -3 then
				sk= 2;
			end;

			lo=sk;
			pic_resp.clear();
			pic_resp.add_part(pic_skala[lo],0,0);
		end;

	if response_manager.total_response_count(2) > confirm then
	end;
		
	tr_resp.present();
	resp=  lo-1;				
end;

resfile.print(thiscond);
resfile.print("\t");
resfile.print(thiscond);
resfile.print("\t");
resfile.print(resp);	
resfile.print("\n");

tr=tr+1;
	
end;			
resfile.close();

# Stop the eye-tracker
arrington.send_code(23);