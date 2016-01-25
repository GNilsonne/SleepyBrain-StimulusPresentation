#########################################################
# This experiment presents a fixation cross and asks the
# subject to rate their sleepiness with the Karolinska
# Sleepiness Scale.
# This version of the script is for use between scans and
# therefore has no scanner sync.
#
# By Gustav Nilsonne 120625
# Free to use with attribution.
#########################################################

scenario = "KSS_brief3";

scenario_type = trials;
         
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
array{
bitmap { filename = "KSS1.jpg";} ;
bitmap { filename = "KSS2.jpg";} ;
bitmap { filename = "KSS3.jpg";} ;
bitmap { filename = "KSS4.jpg";} ;
bitmap { filename = "KSS5.jpg";} ;
bitmap { filename = "KSS6.jpg";} ;
bitmap { filename = "KSS7.jpg";} ;
bitmap { filename = "KSS8.jpg";} ;
bitmap { filename = "KSS9.jpg";} ;
} pic_skala;

# TRIALS #
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
		#duration = 	4000; # This will later be defined in the pcl
      #code = "condition";
      #port_code = 99;
      } ev_rate;	
} tr_rate;   

###############
begin_pcl;
###############

# ENTER DEFAULT SETTINGS
default.present();
parameter_window.remove_all();

# Define output file
output_file resfile = new output_file;
resfile.open("KSS_brief3.txt", false);
resfile.print("KSS_Ratings");

# START EXPERIMENT
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
resfile.close();