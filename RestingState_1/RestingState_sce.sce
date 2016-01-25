####################################################
# This scenario displays a fixation cross for 9 min
# and is intended to be used for a run of resting
# state data acquisition.
# 
# By Gustav Nilsonne 120625
# Free to use with attribution
####################################################

scenario = "RestingState_sce";
scenario_type = fMRI;
pulses_per_scan=1;
pulse_code=115;

response_logging = log_active; # Log only if response is expected
response_matching = simple_matching;

default_background_color = 100,100,100; # Gray background makes for more comfortable viewing during a long run
default_font = "Verdana";                                    

#######################################
begin;
#######################################

# Fixation cross
picture {text {caption = "+"; font_size=100; font_color = 255,255,255,;}; x=0;y=0;} fixation_cross;

# Trial
trial {     
   trial_duration = stimuli_length;
   trial_type = fixed;
	all_responses = false;	
	stimulus_event{  
      picture fixation_cross;	
		duration = 480000; # 8 minutes
   } ev_fixcross;                
}tr_fixcross;   

#######################################
begin_pcl;
#######################################
output_port arrington = output_port_manager.get_port(1);

# Get fMRI trigger pulse
int pulses=pulse_manager.main_pulse_count();
loop until (pulse_manager.main_pulse_count() > pulses)
begin
end;

# Start the eye-tracker
arrington.send_code(21);

# Show fixation cross
tr_fixcross.present();

# Stop the eye-tracker
arrington.send_code(23);