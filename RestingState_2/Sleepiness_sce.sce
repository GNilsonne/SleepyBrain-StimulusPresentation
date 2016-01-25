#########################################################
# This experiment presents a fixation cross and asks the
# subject to rate their sleepiness with the Karolinska
# Sleepiness Scale at intervals.
#
# By Gustav Nilsonne 121210
# Free to use with attribution.
#########################################################

scenario = "Sleepiness_sce";

scenario_type = fMRI;
pulses_per_scan = 1;
pulse_code = 115;
         
active_buttons = 3;
button_codes = 1,2,3;
response_logging = log_active;  #log only if response is expected
response_matching = simple_matching;

default_background_color = 100, 100, 100; # Gray   
default_font_size = 30;
default_text_color = 255,255,255;
default_font = "Verdana";                                    

#######################################
begin;
#######################################

text { caption = "XXX"; 
font_size =20;
preload = false; 
} gap; 

# FIXATION CROSS #
picture {text {caption = "+"; font_size=100; font_color = 255,255,255,;}; x=0;y=0;} fixation_cross;
picture {} default;

# PICTURES FOR KAROLINSKA SLEEPINESS SCALE RATINGS #
TEMPLATE "KSS.tem";

# TRIALS #
# Fixation cross
trial {     
   trial_duration = stimuli_length;
   trial_type = fixed;
	all_responses = false;	
      stimulus_event{  #intertrial interval, fixation cross
      picture fixation_cross;
		time = 0;		
		duration = 120000; # Two minutes
      code = "ITI";
      } ev_fixcross;                
}tr_fixcross; 

# Karolinska Sleepiness Scale Rating
trial {
	all_responses = true;
	trial_duration = stimuli_length;
   trial_type = fixed;
   stimulus_event{  # Placeholder event, will be changed to response scale in PCL
      picture {
         text {caption = "Placeholder";}; x = 0; y = 0;
         } pic_KSS;  
		time=0;
      } ev_rate;	
} tr_rate;   

###############
begin_pcl;
###############

default.present();
parameter_window.remove_all();
output_port arrington = output_port_manager.get_port(1);

# Define output file
output_file resfile = new output_file;
resfile.open("KSS.txt", false);
resfile.print("Karolinska Sleepiness Scale Ratings");

# Get fMRI trigger pulse
int pulses=pulse_manager.main_pulse_count();
loop until (pulse_manager.main_pulse_count() > pulses)
begin
end;

# Start the eye-tracker
arrington.send_code(21);

# START EXPERIMENT
# Loop over 4 trials
loop int tr=1; until tr > 4 begin

# Present fixation cross
	tr_fixcross.present();
	
# Rate sleepiness
	int lo = 5;
	int rating = 5;
	
	int confirm = response_manager.total_response_count(2); 
	int right = response_manager.total_response_count(3); 
	int left = response_manager.total_response_count(1);
	int movement = 0;	
	
	pic_KSS.add_part(pic_skala[5],0,0);

	loop
		until 
			response_manager.total_response_count(2) > confirm 
		begin 
			if response_manager.total_response_count(1) > left then 
				movement = movement -1;
				left = response_manager.total_response_count(1);
			
				if movement >= 4 then
					movement = 4
				end;
				if movement <= -4 then
					movement = -4
				end;
			
				int sk = 5;
				if movement == 4 then
					sk= 9;
					elseif movement == 3 then
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
					elseif movement == -4 then
					sk= 1;
				end;

				lo=sk;
				pic_KSS.clear();
				pic_KSS.add_part(pic_skala[lo],0,0);
				
			elseif response_manager.total_response_count(3) > right then 
				movement = movement + 1;
				right = response_manager.total_response_count(3);	
	
				if movement >= 4 then
					movement = 4
				end;
				if movement <= -4 then
					movement = -4
				end;
			
				int sk = 5;
				if movement == 4 then
					sk= 9;
					elseif movement == 3 then
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
					elseif movement == -4 then
					sk= 1;
				end;

				lo=sk;
				pic_KSS.clear();
				pic_KSS.add_part(pic_skala[lo],0,0);
			end;
	
		if response_manager.total_response_count(2) > confirm then
		end;
		
		tr_rate.present();
		rating =  lo;				
	end;

	resfile.print("\n");
	resfile.print(rating);
tr = tr+1;
end;
resfile.close();

# Stop the eye-tracker
arrington.send_code(23);