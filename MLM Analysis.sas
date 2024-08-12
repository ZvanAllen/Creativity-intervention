 
							*********************************
 							*******Zacks MA Thesis MLM*******
 							*********************************	



*********************************
***Analyses Across Daily logs****
*********************************;

*Reading in WBC Dataset V8a.sav;

proc import datafile= 'C:\Users\Zack\Desktop\Current Projects\Openness Project\Data\WBC Dataset V8a.sav'
out= wbcMasterDaily dbms = sav replace;
run;

proc print data=wbcMasterDaily (obs=10);
run;

*######Variable Names#######
*PA = Postive Affect
*NA = Negative Affect
*wc = Word Count (total words per written task)
*Fatigue/serenity = subscales of PANAS
*Authenticity/Effort = measure assessing how authentic behaviour is and how much effort required
*IPIP_Openness = A measure of trait Openness (from the IPIP-120 scale)

*#####DVs assessed after daily tasks#####:
Creative thinking (not scored yet)
Authenticity/Effort
PA & NA


*Reading in daily data long;

data wbc_daily; set wbcMasterDaily;
 	array dailypa [5] PAT2-PAT6;                                                                      
	array dailyna [5] NAT2-NAT6;
 	array dailywc [5] WordCountT2-WordCountT6;
 	array dailyfatigue [5] FatigueT2-FatigueT6;
 	array dailyserenity [5] SerenityT2-SerenityT6;
 	array dailyauthenticity [5] AuthenticityT2-AuthenticityT6;
 	array dailyeffort [5] EffortT2-EffortT6;		
 	 	do t = 1 to 5;
		  	Daily_PA = dailypa[t];
 	 	 	Daily_NA = dailyna[t];
 		 	Daily_WC = dailywc[t];
		 	Daily_Fatigue = dailyfatigue[t];
 			Daily_Serenity = dailyserenity[t];
 	 	 	Daily_Authenticity = dailyauthenticity[t];
 		 	Daily_Effort = dailyeffort[t];
 		 	Time = t;
 	 	output;
 	  	end;
 	keep ID Condition Time IPIP_Openness Daily_PA Daily_NA
 		 Daily_WC Daily_Fatigue Daily_Serenity Daily_Authenticity 
 		 Daily_Effort;
run;

proc print data=wbc_daily (obs=10);
run;

*Centering; 
*copying variables for later standardizing;
*pc person mean centered, gc grand mean centered;

data wbc_daily_center; set wbc_daily;
 	IPIP_Open_gc = IPIP_Openness;
	Daily_PA_pc = Daily_PA;
    Daily_NA_pc = Daily_NA;
    Daily_WC_pc = Daily_WC;
    Daily_Fatigue_pc = Daily_Fatigue;
    Daily_Serenity_pc = Daily_Serenity;
    Daily_Authenticity_pc = Daily_Authenticity;
    Daily_Effort_pc = Daily_Effort;
	Daily_PA_gc = Daily_PA;
    Daily_NA_gc = Daily_NA;
    Daily_WC_gc = Daily_WC;
    Daily_Fatigue_gc = Daily_Fatigue;
    Daily_Serenity_gc = Daily_Serenity;
    Daily_Authenticity_gc = Daily_Authenticity;
    Daily_Effort_gc = Daily_Effort;
run;

proc print data = wbc_daily_center (obs=10);
run;

*person mean centering; *dont need to do this;

proc standard data = wbc_daily_center m=0 out=dailypc;
	by ID;
	var Daily_PA_pc Daily_NA_pc Daily_WC_pc Daily_Fatigue_pc 
    Daily_Serenity_pc Daily_Authenticity_pc Daily_Effort_pc;
run;

proc print data = dailypc (obs=10);
run;

*grand mean centering;
*this makes 'daily_centered' final dataset for mlm across daily logs;

proc standard data = dailypc m=0 out=daily_centered;
	var IPIP_Open_gc Daily_PA_gc Daily_NA_gc Daily_WC_gc Daily_Fatigue_gc 
    Daily_Serenity_gc Daily_Authenticity_gc Daily_Effort_gc;
run;

proc print data = daily_centered (obs=10);
run;

**********************
*****Authenticity*****
**********************;

proc sort data=wbcMasterDaily out = wbcMasterDaily_sorted;
 by Condition;
 run;
 proc sort data = daily_centered out = daily_centered_sorted;
 by Condition;
 run;


*Descriptives;
proc means data = daily_centered;
var IPIP_Openness;
run;
proc means data = wbcMasterDaily_sorted;
by Condition;
var AuthenticityT2 AuthenticityT3 AuthenticityT4 AuthenticityT5 AuthenticityT6;
run;
proc means data = daily_centered_sorted;
by Condition;
var Daily_Authenticity;
run;

*Model A (unconditional);

*
Covariance Parameter Estimates 
Cov Parm Subject Estimate Standard Error Z Value Pr > Z 
UN(1,1)    ID 	  1.0337 		0.1156	 8.94 	<.0001 
Residual   		  0.6570 		0.03410 19.27 	<.0001 
;

*
Solution for Fixed Effects 
Effect   Estimate StandardError   DF    t Value   Pr > |t| 
Intercept 5.4870    0.09168      219   59.85      <.0001 
Time      0.07357   0.01882      745    3.91      0.0001 
;

proc mixed data= daily_centered method=reml noclprint covtest;
	class ID;
	model Daily_Authenticity = time /ddfm=bw solution;
	random intercept /subject=ID type=un;
run;

*Model B;

*
Covariance Parameter Estimates 
Cov Parm Subject Estimate Standard Error Z Value Pr > Z 
UN(1,1)    ID 	  1.0788 	0.1828 		5.90 	<.0001 
UN(2,1)    ID 	 -0.04697 	0.03668    -1.28 	0.2003 
UN(2,2)    ID 	  0.02925 	0.01077 	2.72 	0.0033 
Residual   		  0.5862 	0.03622 	16.18 	<.0001 
;

*
Solution for Fixed Effects 
Effect     Estimate Standard Error   DF   t Value    Pr > |t| 
Intercept 5.4952 	0.09099 		219 	60.39 	<.0001 
Time 	  0.07005 	0.02157 		745 	3.25 	0.0012 
;

proc mixed data= daily_centered method=reml noclprint covtest;
	class ID;
	model Daily_Authenticity = Time/ddfm=bw solution;
	random intercept Time /subject=ID type=un;
run;

*Model C;

*
Covariance Parameter Estimates 
Cov Parm Subject Estimate Standard Error Z Value Pr > Z 
UN(1,1) 	ID 		1.0881 	0.1841 		5.91 	<.0001 
UN(2,1) 	ID 	   -0.04837 0.03693    -1.31 	0.1903 
UN(2,2) 	ID 		0.02980 0.01085 	2.75 	0.0030 
Residual   			0.5860 	0.03621 	16.18 	<.0001
;

*
Solution for Fixed Effects 
Effect    		Estimate      StandardError   DF   t Value    Pr > |t| 
Intercept 		5.4788 			0.1264		 218 	43.35 		<.0001 
Time 			0.07346 		0.02997 	 744 	2.45 		0.0145 
Condition 		0.03442 		0.1826 		 218 	0.19 		0.8507 
Time*Condition -0.00718 		0.04330  	 744   -0.17 		0.8683 
;

proc mixed data= daily_centered method=reml noclprint covtest;
	class ID;
	model Daily_Authenticity = Time Condition Time*Condition/ddfm=bw solution;
	random intercept Time /subject=ID type=un;
run;
*Model D;

*
Covariance Parameter Estimates 
Cov Parm Subject Estimate Standard Error Z Value Pr > Z 
UN(1,1) 	ID 	0.9094 		0.1863 		4.88 	<.0001 
UN(2,1) 	ID 	-0.07333 	0.05364 	-1.37 	0.1716 
UN(2,2) 	ID 	0.08879 	0.02248 	3.95 	<.0001 
Residual   		0.4972 		0.03783 	13.14 	<.0001 

;

*
Solution for Fixed Effects 
Effect    			Estimate      StandardError   DF   t Value    Pr > |t|
Intercept 			5.5878 			0.1309 		216 	42.68 	<.0001 
Time 				0.01226 		0.04626 	548 	0.27 	0.7910 
Condition 			-0.1395 		0.1860 		216 	-0.75 	0.4539 
Time*Condition 		0.06885 		0.06574 	548 	1.05 	0.2954 
IPIP_Open_gc 		-0.02411 		0.2555 		216 	-0.09 	0.9249 
Time*IPIP_Open_gc 	-0.07049 		0.06870 	548 	-1.03 	0.3053 
Condition*IPIP_Open_ 1.2076 		0.3189 		216 	3.79 	0.0002 
Daily_WC_pc 		 0.001419 		0.001423 	548 	1.00 	0.3191 
Time*Daily_WC_pc 	0.000170 		0.000564 	548 	0.30 	0.7627 
Condition*Daily_WC_p 0.000047 		0.000969 	548 	0.05 	0.9613 
;

proc mixed data= daily_centered method=reml noclprint covtest;
    class ID;
	model Daily_Authenticity = Time Condition Time*Condition IPIP_Open_gc IPIP_Open_gc*Time IPIP_Open_gc*Condition Daily_WC_pc 
Time*Daily_WC_pc Daily_WC_pc*Condition/ddfm=bw solution;
	random intercept Time /subject=ID type=un;
run;

*Model E

UN(1,1) ID 0.8952 	0.1830 	4.89 	<.0001 
UN(2,1) ID -0.06917 0.05277 -1.31 	0.1899 
UN(2,2) ID 0.08795 	0.02224 3.95 	<.0001 
Residual   0.4967 	0.03762 13.20 	<.0001 

Effect 				Estimate Standard Error DF t Value Pr > |t| 
Intercept 			5.4884 		0.2373 		216 23.12 <.0001 
Time 				0.04562 	0.03253 	552 1.40 0.1613 
Condition 			0.01888 	0.1439 		216 0.13 0.8958 
IPIP_Open_gc 		2.2730 		0.5032 		216 4.52 <.0001 
Condition*IPIP_Open_ -1.2094 	0.3185 		216 -3.80 0.0002 
Daily_WC_pc 		0.001847 	0.000458 	552 4.03 <.0001 
;
proc mixed data= daily_centered method=reml noclprint covtest;
    class ID;
	model Daily_Authenticity = Time Condition IPIP_Open_gc IPIP_Open_gc*Condition Daily_WC_pc/ddfm=bw solution;
	random intercept Time /subject=ID type=un;
run;
*Probing traitopen*condition
*Estimates 
Label 				Estimate StandardError  DF 		t Value Pr > |t| 
Open Intercept 		5.4483 		0.1323 		216 	41.19 	<.0001 
Open Slope 			1.1835 		0.2548 		216 	4.64 	<.0001 
Control Intercept 	5.5878 		0.1309 		216 	42.68 	<.0001 
Control Slope 		-0.02411 	0.2555 		216 	-0.09 	0.9249 
;

proc mixed data= daily_centered method=reml noclprint covtest;
    class ID;
	model Daily_Authenticity = Time Condition Time*Condition IPIP_Open_gc IPIP_Open_gc*Time IPIP_Open_gc*Condition Daily_WC_pc 
Time*Daily_WC_pc Daily_WC_pc*Condition/ddfm=bw solution;
	random intercept Time /subject=ID type=un;
	estimate 'Open Intercept' intercept 1 Condition 1;
	estimate 'Open Slope'  IPIP_Open_gc 1 IPIP_Open_gc*Condition 1;
	estimate 'Control Intercept' intercept 1 Condition 0;
	estimate 'Control Slope' IPIP_Open_gc 1 IPIP_Open_gc*Condition 0;
run;
*Create dataset for plot;

data DailyAuthPlot;
do i = -.90 to .90 by .45;
Open = 5.45 + 1.18*i;
Control = 5.59 - .02*i;
output; end;
run;
Proc print data=DailyAuthPlot;
run;



**********************
*******Effort*********
**********************;

*Descriptives;
proc means data = wbcMasterDaily_sorted;
by Condition;
var AuthenticityT2 AuthenticityT3 AuthenticityT4 AuthenticityT5 AuthenticityT6;
run;
proc means data = daily_centered_sorted;
by Condition;
var Daily_Authenticity;
run;
*
Covariance Parameter Estimates 
Cov Parm Subject Estimate Standard Error Z Value Pr > Z 
UN(1,1) 	ID 	 1.0653 	0.1187 		8.97 	<.0001 
Residual  		 0.6614 	0.03433 	19.27 	<.0001 
;

*
Solution for Fixed Effects 
Effect	 Estimate 	Standard Error 	DF 	t Value 	Pr > |t| 
Intercept  2.6556     0.09259      219   28.68       <.0001 
Time      -0.1366     0.01889      745   -7.23       <.0001 
;

proc mixed data= daily_centered method=reml noclprint covtest;
	class ID;
	model Daily_Effort = Time /ddfm=bw solution;
	random intercept /subject=ID type=un;
run;

*Model B;

*
Covariance Parameter Estimates 
Cov Parm Subject Estimate Standard Error Z Value Pr > Z 
UN(1,1) 	ID  1.5013 		0.2190 		6.85 	<.0001 
UN(2,1) 	ID -0.1154 		0.04039    -2.86 	0.0043 
UN(2,2) 	ID  0.02953 	0.01032 	2.86 	0.0021 
Residual   		0.5890 		0.03587 	16.42 	<.0001 
;

*
Solution for Fixed Effects 
Effect 		Estimate 	StandardError 	DF 	t Value 	Pr > |t| 
Intercept 	2.6557 			0.1011 		219 26.26 		<.0001 
Time 	   -0.1369 			0.02156 	745 -6.35 		<.0001 
 
;

proc mixed data= daily_centered method=reml noclprint covtest;
	class ID;
	model Daily_Effort = Time/ddfm=bw solution;
	random intercept Time/subject=ID type=un;
run;
 *Model C;

*
Covariance Parameter Estimates 
Cov Parm Subject Estimate Standard Error Z Value Pr > Z
UN(1,1) 	ID 	1.5044 		0.2198 		6.84 	<.0001 
UN(2,1) 	ID -0.1163 		0.04058 	-2.87 	0.0042 
UN(2,2) 	ID 	0.02999 	0.01039 	2.89 	0.0019 
Residual   		0.5888 		0.03586 	16.42 	<.0001 
;

*
Solution for Fixed Effects 
Effect			 Estimate	 StandardError	 DF	 t Value 	Pr > |t| 
Intercept 		2.5736 			0.1402 		218 	18.36 	<.0001 
Time 			-0.1284 		0.02994 	744 	-4.29 	<.0001 
Condition 		0.1713 			0.2026 		218 	0.85 	0.3988 
Time*Condition -0.01764 		0.04325 	744 	-0.41 	0.6836  
;

proc mixed data= daily_centered method=reml noclprint covtest;
	class ID;
	model Daily_Effort = Time Condition Time*Condition/ddfm=bw solution;
	random intercept Time/subject=ID type=un;
run;
*Model D;

*
Covariance Parameter Estimates 
Cov Parm Subject Estimate Standard Error Z Value Pr > Z
UN(1,1)   ID 	1.2533 		0.2469 		5.08 	<.0001 
UN(2,1)   ID 	-0.07338 	0.06194 	-1.18 	0.2362 
UN(2,2)   ID 	0.03546 	0.02084 	1.70 	0.0444 
Residual   		0.6524 		0.04860 	13.42 	<.0001 
;

*
Solution for Fixed Effects 
Effect			 		Estimate	 StandardError	 DF	 t Value 	Pr > |t| 
Intercept 				2.5847 		0.1504 			216 17.18 		<.0001 
Time 					-0.1254 	0.04441 		548 -2.82 		0.0049 
Condition 				0.1153 		0.2140 			216 0.54 		0.5905 
Time*Condition 			0.003521 	0.06281 		548 0.06 		0.9553 
Daily_WC_pc 			-0.00168 	0.001582 		548 -1.06 		0.2884 
IPIP_Open_gc 			0.004944 	0.2867 			216 0.02 		0.9863 
Time*IPIP_Open_gc 		0.04949 	0.06498 		548 0.76 		0.4467 
Condition*IPIP_Open_ 	-0.7052 	0.3419 			216 -2.06 		0.0403 
Time*Daily_WC_pc 		-0.00004 	0.000618 		548 -0.07 		0.9455 
Condition*Daily_WC_p 	0.002441 	0.001075 		548 2.27 		0.0235 

;

proc mixed data= daily_centered method=reml noclprint covtest;
    class ID;
	model Daily_Effort = Time Condition Time*Condition Daily_WC_pc IPIP_Open_gc IPIP_Open_gc*Time IPIP_Open_gc*Condition Time*Daily_WC_pc Daily_WC_pc*Condition/ddfm=bw solution;
	random intercept Time /subject=ID type=un;
run;
*
Label Estimate Standard Error DF t Value Pr > |t| 
Open Intercept 2.7000 0.1525 216 17.71 <.0001 
Open Slope -0.7003 0.2870 216 -2.44 0.0155 
Control Intercept 2.5847 0.1504 216 17.18 <.0001 
Control Slope 0.004944 0.2867 216 0.02 0.9863 
;

proc mixed data= daily_centered method=reml noclprint covtest;
    class ID;
	model Daily_Effort = Time Condition Time*Condition Daily_WC_pc IPIP_Open_gc IPIP_Open_gc*Time IPIP_Open_gc*Condition Time*Daily_WC_pc Daily_WC_pc*Condition/ddfm=bw solution;
	random intercept Time /subject=ID type=un;
	estimate 'Open Intercept' intercept 1 Condition 1;
	estimate 'Open Slope'  IPIP_Open_gc 1 IPIP_Open_gc*Condition 1;
	estimate 'Control Intercept' intercept 1 Condition 0;
	estimate 'Control Slope' IPIP_Open_gc 1 IPIP_Open_gc*Condition 0;
run;

data DailyEffortPlot;
do i = -.90 to .90 by .45;
Open = 2.7 - .7*i;
Control = 2.58 + .005*i;
output; end;
run;
proc print data  = DailyEffortPlot;
run;

* condition* WC;
proc mixed data= daily_centered method=reml noclprint covtest;
    class ID;
	model Daily_Effort = Time Condition Time*Condition Daily_WC_pc IPIP_Open_gc IPIP_Open_gc*Time IPIP_Open_gc*Condition Time*Daily_WC_pc Daily_WC_pc*Condition/ddfm=bw solution;
	random intercept Time /subject=ID type=un;
	estimate 'Open Intercept' intercept 1 Condition 1;
	estimate 'Open Slope'  Daily_WC_pc 1 Daily_WC_pc*Condition 1;
	estimate 'Control Intercept' intercept 1 Condition 0;
	estimate 'Control Slope' Daily_WC_pc 1 Daily_WC_pc*Condition 0;
run;

*Model E

Cov Parm Subject 	Estimate Standard Error Z Value Pr Z 
UN(1,1) ID 			1.2422 		0.2439 		5.09 <.0001 
UN(2,1) ID 			-0.06955 	0.06117 	-1.14 0.2555 
UN(2,2) ID			 0.03439 	0.02059 	1.67 0.0474 
Residual   			0.6507 		0.04840 	13.44 <.0001 


Effect 				Estimate Standard Error DF t Value Pr > |t| 
Intercept 			2.8277 		0.2583 		216 10.95 	<.0001 
Time 				-0.1234 	0.03117 	551 -3.96 	<.0001 
Condition 			-0.1234 	0.1548 		216 -0.80 	0.4262 
Daily_WC_pc 		0.003047 	0.001484 	551 2.05 	0.0405 
IPIP_Open_gc 		-1.2896 	0.5398 		216 -2.39 	0.0178 
Condition*IPIP_Open_ 0.7060 	0.3419 		216 2.06 	0.0402 
Condition*Daily_WC_p -0.00240 	0.001020 	551 -2.35 	0.0190 
;

proc mixed data= daily_centered method=reml noclprint covtest;
    class ID;
	model Daily_Effort = Time Condition Daily_WC_pc IPIP_Open_gc IPIP_Open_gc*Condition Daily_WC_pc*Condition/ddfm=bw solution;
	random intercept Time /subject=ID type=un;
run;

****************************
********Affect - PA ********
****************************;

*Descriptives;
proc means data = wbcMasterDaily_sorted;
by Condition;
var PAT2 PAT3 PAT4 PAT5 PAT6;
run;
proc means data = daily_centered_sorted;
by Condition;
var Daily_PA;
run;
*Model A (unconditional);

*
Covariance Parameter Estimates 
Cov Parm Subject Estimate Standard Error Z Value Pr > Z
UN(1,1) 	ID  0.4716 		0.05326 	  8.86   <.0001 
Residual   		0.3280 		0.01701 	  19.28  <.0001 
;

*
Solution for Fixed Effects 
Effect     Estimate     Standard Error     DF    t Value     Pr > |t| 
Intercept 2.7587 		0.06319 		219 	43.66 		<.0001 
Time 	-0.06354 		0.01329 		745 	-4.78 		<.0001 
;

proc mixed data= daily_centered method=reml noclprint covtest;
    class ID;
	model Daily_PA = Time /ddfm=bw solution;
	random intercept /subject=ID type=un;
run;

*Model B;

*
Cov Parm Subject Estimate Standard Error Z Value Pr > Z 
UN(1,1) 	ID  0.6654 		0.1011 		6.58 	<.0001 
UN(2,1) 	ID -0.05441 	0.01946 	-2.80 	0.0052 
UN(2,2) 	ID  0.01528 	0.005038 	3.03 	0.0012 
Residual   		0.2906 		0.01751 	16.60 	<.0001 
;

*
Solution for Fixed Effects 
Effect		 Estimate	 Standard Error	 DF 	t Value Pr	 > |t|  
Intercept 	2.7604 		0.06858 		219 	40.25 	<.0001 
Time 		-0.06398 	0.01526 		745 	-4.19 	<.0001 
;

proc mixed data= daily_centered method=reml noclprint covtest;
	class ID;
	model Daily_PA = Time/ddfm=bw solution;
	random intercept Time /subject=ID type=un;
run;

*Model C;

*
Cov Parm Subject Estimate Standard Error Z Value Pr > Z 
UN(1,1)   ID 	0.6442 		0.09946 	6.48 	<.0001 
UN(2,1)   ID   -0.05176 	0.01927    -2.69 	0.0072 
UN(2,2)   ID 	0.01507 	0.005033 	2.99 	0.0014 
Residual   		0.2907 		0.01752 	16.59 	<.0001 
;

*
Solution for Fixed Effects 
Effect 			Estimate	 StandardError	 DF 	t Value 	Pr > |t| 
Intercept 		2.6115 		0.09403 		218 	27.77 		<.0001 
Time 			-0.04412 	0.02110 		744 	-2.09 		0.0369 
Condition 		0.3109 		0.1359 			218 	2.29 		0.0231 
Time*Condition -0.04140 	0.03048 		744 	-1.36 		0.1748 

;

proc mixed data= daily_centered method=reml noclprint covtest;
	class ID;
	model Daily_PA = Time Condition Time*Condition/ddfm=bw solution;
	random intercept Time /subject=ID type=un;
run;

*Model D;

*
Cov Parm Subject Estimate Standard Error Z Value Pr > Z
UN(1,1)   ID 	0.4679 		0.09425 	4.96 	<.0001 
UN(2,1)   ID 	-0.00758 	0.02356 	-0.32 	0.7478 
UN(2,2)   ID 	0.01174 	0.008182 	1.43 	0.0758 
Residual   		0.2603 		0.01944 	13.39 	<.0001 
 
;

*
Solution for Fixed Effects 
Effect 			   	Estimate	 StandardError	 DF 	t Value 	Pr > |t| 
Intercept 			2.6918 			0.09340 	216 	28.82 		<.0001 
Time 				-0.09320 		0.02766 	548 	-3.37 		0.0008 
Condition 			0.2679 			0.1328 		216 	2.02 		0.0449 
Time*Condition 		-0.01881 		0.03910 	548 	-0.48 		0.6306 
Daily_WC_pc 		0.001020 		0.000994 	548 	1.03 		0.3054 
IPIP_Open_gc 		-0.3674 		0.1824 		216 	-2.01 		0.0453 
Time*IPIP_Open_gc 	0.02718 		0.04036 	548 	0.67 		0.5010 
Condition*IPIP_Open_ 0.7945 		0.2269 		216 	3.50 		0.0006 
Time*Daily_WC_pc 	0.000389 		0.000390 	548 	1.00 		0.3191 
Condition*Daily_WC_p -0.00118 		0.000676 	548 	-1.74 		0.0821 

;

proc mixed data= daily_centered method=reml noclprint covtest;
    class ID;
	model Daily_PA = Time Condition Time*Condition Daily_WC_pc IPIP_Open_gc IPIP_Open_gc*Time IPIP_Open_gc*Condition Time*Daily_WC_pc Daily_WC_pc*Condition/ddfm=bw solution;
	random intercept Time /subject=ID type=un;
run;
*
Open Intercept 2.9597 0.09459 216 31.29 <.0001 
Open Slope 0.4272 0.1824 216 2.34 0.0201 
Control Intercept 2.6918 0.09340 216 28.82 <.0001 
Control Slope -0.3674 0.1824 216 -2.01 0.0453 
;

proc mixed data= daily_centered method=reml noclprint covtest;
    class ID;
	model Daily_PA = Time Condition Time*Condition Daily_WC_pc IPIP_Open_gc IPIP_Open_gc*Time IPIP_Open_gc*Condition Time*Daily_WC_pc Daily_WC_pc*Condition/ddfm=bw solution;
	random intercept Time /subject=ID type=un;
	estimate 'Open Intercept' Intercept 1 Condition 1;
	estimate 'Open Slope'  IPIP_Open_gc 1 IPIP_Open_gc*Condition 1;
	estimate 'Control Intercept' intercept 1 Condition 0;
	estimate 'Control Slope' IPIP_Open_gc 1 IPIP_Open_gc*Condition 0;
run;

data DailyPAPlot;
do i = -.90 to .90 by .45;
Open = 2.96 + .43*i;
Control = 2.69 - .37*i;
output; end;
run;
Proc print data=DailyPAPlot;
run;

proc mixed data= daily_centered method=reml noclprint covtest;
    class ID;
	model Daily_PA = Time Condition Time*Condition Daily_WC_pc IPIP_Open_gc IPIP_Open_gc*Time IPIP_Open_gc*Condition Time*Daily_WC_pc Daily_WC_pc*Condition/ddfm=bw solution;
	random intercept Time /subject=ID type=un;
	estimate 'Open Intercept' Intercept 1 Condition 1;
	estimate 'Open Slope'  Daily_WC_pc 1 Daily_WC_pc*Condition 1;
	estimate 'Control Intercept' intercept 1 Condition 0;
	estimate 'Control Slope' Daily_WC_pc 1 Daily_WC_pc*Condition 0;
run;
*Model E

Cov Parm Subject Estimate Standard Error Z Value Pr Z 
UN(1,1) ID 		0.4547 		0.09300 	4.89 	<.0001 
UN(2,1) ID 		-0.00273 	0.02309 	-0.12	0.9060 
UN(2,2) ID 		0.01005 	0.008022 	1.25 	0.1051 
Residual   		0.2626 		0.01955 	13.43 	<.0001 

Effect 				Estimate Standard Error DF t Value Pr > |t| 
Intercept 			3.1639 		0.1693 		216 18.68 <.0001 
Time 				-0.1060 	0.01921 	552 -5.52 <.0001 
Condition 			-0.2248 	0.1026 		216 -2.19 0.0295 
Daily_WC_pc 		0.001171 	0.000322 	552 3.64 0.0003 
IPIP_Open_gc 		1.2851 		0.3585 		216 3.58 0.0004 
Condition*IPIP_Open_ -0.7981 	0.2270 		216 -3.52 0.0005 ;

proc mixed data= daily_centered method=reml noclprint covtest;
    class ID;
	model Daily_PA = Time Condition Daily_WC_pc IPIP_Open_gc IPIP_Open_gc*Condition/ddfm=bw solution;
	random intercept Time /subject=ID type=un;
run;

****************************
********Affect - NA ********
****************************;

*Descriptives;
proc means data = wbcMasterDaily_sorted;
by Condition;
var NAT2 NAT3 NAT4 NAT5 NAT6;
run;
proc means data = daily_centered_sorted;
by Condition;
var Daily_NA;
run;
proc means data = daily_centered_sorted;
var Daily_WC_pc;
run;

*Model A (unconditional);

*
Solution for Fixed Effects 
Effect 	Subject	Estimate StandardError  Z Value  Pr > |t| 
UN(1,1)   ID	 0.4516 	0.04760 	9.49 	<.0001 
Residual   		 0.1852 	0.009592 	19.31 	<.0001 

;

*
Solution for Fixed Effects 
Effect 		Estimate StandardError  DF 		t Value  Pr > |t| 
Intercept	 1.7476 	0.05567 	219 	31.39     <.0001 
Time 		-0.06204 	0.01001 	745 	-6.20     <.0001 
;

proc mixed data= daily_centered method=reml noclprint covtest;
    class ID;
	model Daily_NA = Time /ddfm=bw solution;
	random intercept /subject=ID type=un;
run;


*Model B;

*Covariance Parameter Estimates 
Cov Parm Subject Estimate Standard Error 	Z Value 	Pr Z 
UN(1,1) 	ID 	0.5236 		0.07257 		7.21 		<.0001 
UN(2,1) 	ID -0.02004 	0.01154 		-1.74 		0.0823 
UN(2,2) 	ID  0.005700 	0.002734 		2.09 		0.0185 
Residual   		0.1712 		0.01042 		16.44 		<.0001 
;

*
Solution for Fixed Effects 
Effect	 Estimate	 StandardError	 DF	 t Value 	Pr > |t| 
Intercept 1.7481 		0.05800 	219   30.14 	<.0001 
Time 	 -0.06185 		0.01102 	745   -5.61 	<.0001 
;

*varation in intercept and slope could potentially be explained
b a level 2 (between-person)predictor -- Time subsequently modelled
as random;

proc mixed data= daily_centered method=reml noclprint covtest;
    class ID;
	model Daily_NA = Time/ddfm=bw solution;
	random intercept Time/subject=ID type=un;
run;

*Model C;

*
Covariance Parameter Estimates 
Cov Parm Subject Estimate Standard Error 	Z Value 	Pr Z
UN(1,1) 	ID  0.5180 		0.07221			 7.17 		<.0001 
UN(2,1) 	ID -0.01706 	0.01126 		-1.52 		0.1297 
UN(2,2) 	ID  0.004433 	0.002628 		 1.69 		0.0458 
Residual   		0.1717 		0.01044         16.45 		<.0001 
;

*
Solution for Fixed Effects 
Effect 			Estimate StandardError   DF    t Value 	Pr > |t| 
Intercept 		1.6793 		0.08001 	218 	20.99 	<.0001 
Time 		   -0.02913 	0.01489 	744 	-1.96 	0.0507 
Condition        0.1431 	0.1157 		218 	1.24 	0.2173 
Time*Condition  -0.06844 	0.02149 	744 	-3.18 	0.0015 
;

proc mixed data= daily_centered method=reml noclprint covtest;
    class ID;
	model Daily_NA = Time Condition Time*Condition/ddfm=bw solution;
	random intercept Time/subject=ID type=un;
run;

*Model D;

*
Covariance Parameter Estimates 
Cov Parm Subject Estimate Standard Error 	Z Value 	Pr Z
UN(1,1)    ID 	0.5300 		0.08531 		6.21 		<.0001 
UN(2,1)    ID   -0.02646 	0.01921 		-1.38 		0.1684 
UN(2,2)    ID   0.01090 	0.005972 		1.82 		0.0340 
Residual   		0.1747 		0.01316 		13.28 		<.0001 
;

*
Solution for Fixed Effects 
Effect 				Estimate StandardError   DF    t Value 	Pr > |t| 
Intercept 			1.6229 		0.08827 	216 	18.39 	<.0001 
Time 				-0.00724 	0.02337 	548 	-0.31 	0.7569 
Condition 			0.1224 		0.1259 		216 	0.97 	0.3323 
Time*Condition 		-0.06133 	0.03304 	548 	-1.86 	0.0640 
Daily_WC_pc 		0.001297 	0.000829 	548 	1.56 	0.1185 
IPIP_Open_gc 		-0.02762 	0.1740 		216 	-0.16 	0.8741 
Time*IPIP_Open_gc 	0.009517 	0.03419 	548 	0.28 	0.7808 
Condition*IPIP_Open_ -0.1330 	0.2160 		216 	-0.62 	0.5387 
Time*Daily_WC_pc 	-0.00047 	0.000325 	548 	-1.45 	0.1483 
Condition*Daily_WC_p 0.001542 	0.000559 	548 	2.76 	0.0060 
;

proc mixed data= daily_centered method=reml noclprint covtest;
    class ID;
	model Daily_NA = Time Condition Time*Condition Daily_WC_pc IPIP_Open_gc IPIP_Open_gc*Time IPIP_Open_gc*Condition Time*Daily_WC_pc Daily_WC_pc*Condition/ddfm=bw solution;
	random intercept Time /subject=ID type=un;
run;
*
Open Intercept 1.7453 0.08997 216 19.40 <.0001 
Open Slope -0.06856 0.02327 548 -2.95 0.0034 
Control Intercept 1.6229 0.08827 216 18.39 <.0001 
Control Slope -0.00724 0.02337 548 -0.31 0.7569 
;

proc mixed data= daily_centered method=reml noclprint covtest;
    class ID;
	model Daily_NA = Time Condition Time*Condition Daily_WC_pc IPIP_Open_gc IPIP_Open_gc*Time IPIP_Open_gc*Condition Time*Daily_WC_pc Daily_WC_pc*Condition/ddfm=bw solution;
	random intercept Time /subject=ID type=un;
	estimate 'Open Intercept' Intercept 1 Condition 1;
	estimate 'Open Slope'  Time 1 Time*Condition 1;
	estimate 'Control Intercept' intercept 1 Condition 0;
	estimate 'Control Slope' Time 1 Time*Condition 0;
run;

data DailyNAPlot;
do time = 1 to 5;
Open = 1.75 - .069*time;
Control = 1.62 - .007*time;
output; end;
run;
Proc print data=DailyNAPlot;
run;
*
Open Intercept 1.7453 0.08997 216 19.40 <.0001 
Open Slope 0.002839 0.000849 548 3.34 0.0009 
Control Intercept 1.6229 0.08827 216 18.39 <.0001 
Control Slope 0.001297 0.000829 548 1.56 0.1185 
;

proc mixed data= daily_centered method=reml noclprint covtest;
    class ID;
	model Daily_NA = Time Condition Time*Condition Daily_WC_pc IPIP_Open_gc IPIP_Open_gc*Time IPIP_Open_gc*Condition Time*Daily_WC_pc Daily_WC_pc*Condition/ddfm=bw solution;
	random intercept Time /subject=ID type=un;
	estimate 'Open Intercept' Intercept 1 Condition 1;
	estimate 'Open Slope'  Daily_WC_pc 1 Daily_WC_pc*Condition 1;
	estimate 'Control Intercept' intercept 1 Condition 0;
	estimate 'Control Slope' Daily_WC_pc 1 Daily_WC_pc*Condition 0;
run;

data DailyNAPlot;
do i = -60.79 to 60.79 by 60.79;
Open = 1.745 + .0028*i;
Control = 1.623 + .0013*i;
output; end;
run;
proc print data = DailyNAPlot;
run;
*Model E

Cov Parm Subject Estimate Standard Error Z Value Pr Z 
UN(1,1) ID 		0.5144 		0.08328 	6.18 <.0001 
UN(2,1) ID 		-0.02273 	0.01876 	-1.21 0.2256 
UN(2,2) ID 		0.009939 	0.005884 	1.69 0.0456 
Residual   		0.1763 		0.01323 	13.32 <.0001 


Effect 				Estimate Standard Error DF t Value Pr > |t| 
Intercept 			1.8566 		0.1986 		217 9.35 	<.0001 
Time 				-0.1234 	0.05165 	550 -2.39 	0.0172 
Condition 			-0.1105 	0.1247 		217 -0.89 	0.3763 
Time*Condition 		0.05711 	0.03272 	550 1.75 	0.0815 
Daily_WC_pc 		0.003128 	0.000800 	550 3.91 	0.0001 
IPIP_Open_gc 		-0.07186 	0.1077 		217 -0.67 	0.5054 
Condition*Daily_WC_p -0.00143 	0.000554 	550 -2.58 	0.0102 
;

proc mixed data= daily_centered method=reml noclprint covtest;
    class ID;
	model Daily_NA = Time Condition Time*Condition Daily_WC_pc IPIP_Open_gc Daily_WC_pc*Condition/ddfm=bw solution;
	random intercept Time /subject=ID type=un;
run;



**********************
******Creativity******
**********************;

*Model A (unconditional);

*Model B;

*Model C;

*Model D;







***************************************************************************************************************************************************************
***************************************************************************************************************************************************************
***************************************************************************************************************************************************************




************************************************
***Analyses Across Pretest/Posttest/Posttest****
************************************************;

proc import datafile= 'C:\Users\Zack\Desktop\Current Projects\Openness Project\Data\WBC Dataset V8b.sav' out= wbcMasterPPP dbms = sav replace;
run;

proc print data=wbcMasterPPP (obs=10);
run;
*Creating long data set with pre/post/post variables;

data wbc_prepostpost; set wbcMasterPPP;
 	array ppppa [3] PAppp1-PAppp3; 		 		
 	array pppna [3] NAppp1-NAppp3;
 	array pppfatigue [3] Fatigueppp1-Fatigueppp3;			
 	array pppserenity [3] Serenityppp1-Serenityppp3;
 	array ppppg [3]PGppp1-PGppp3;
 	array ppppresence [3]Presenceppp1-Presenceppp3;
 	array pppsearch [3] Searchppp1-Searchppp3;
 	array pppswls [3] SWLSppp1-SWLSppp3;
 	array pppmilq [3]MILQppp1-MILQppp3;
 	array pppauthenticity [3]Authenticityppp1-Authenticityppp3;
 	array pppeffort [3] Effortppp1-Effortppp3;
 		do t = 1 to 3;
 			PPP_PA = ppppa[t];
 			PPP_NA = pppna[t];
 			PPP_Fatigue = pppfatigue[t];
 			PPP_Serenity = pppserenity[t];
 			PPP_PG = ppppg[t];
 			PPP_Presence = ppppresence[t];
 			PPP_Search = pppsearch[t];
 			PPP_SWLS = pppswls[t];
 			PPP_MILQ = pppmilq[t];
 			PPP_Authenticity = pppauthenticity[t];
 			PPP_Effort = pppeffort[t];
		 	Time = t-1;
 	 	output;
 	 	end;
 	keep ID Condition Time IPIP_Openness PPP_PA PPP_NA PPP_Fatigue PPP_Serenity
 		 PPP_PG PPP_Presence PPP_Search PPP_SWLS PPP_MILQ PPP_Authenticity
 		 PPP_Effort WordCountMean;
run;

*milq not included in V8b--left as is;

proc print data= wbc_prepostpost (obs=10);
run;

*Centering; 
*copying variables for later standardizing;
*pc person mean centered, gc grand mean centered;

data wbc_ppp_center; set wbc_prepostpost;
IPIP_Open_gc = IPIP_Openness;
PPP_PA_pc = PPP_PA;
PPP_NA_pc = PPP_NA;
PPP_Fatigue_pc = PPP_Fatigue;
PPP_Serenity_pc = PPP_Serenity;
PPP_PG_pc = PPP_PG;
PPP_Presence_pc = PPP_Presence;
PPP_Search_pc = PPP_Search;
PPP_SWLS_pc = PPP_SWLS;
PPP_Authenticity_pc = PPP_Authenticity;
PPP_Effort_pc = PPP_Effort;
PPP_PA_gc = PPP_PA;
PPP_NA_gc = PPP_NA;
PPP_Fatigue_gc = PPP_Fatigue; 
PPP_Serenity_gc = PPP_Serenity;
PPP_PG_gc = PPP_PG;
PPP_Presence_gc = PPP_Presence;
PPP_Search_gc = PPP_Search;
PPP_SWLS_gc = PPP_SWLS;
PPP_Authenticity_gc = PPP_Authenticity;
PPP_Effort_gc = PPP_Effort;
run;

proc print data = wbc_ppp_center (obs=10);
run;

*person mean centering;

proc standard data = wbc_ppp_center m=0 out=ppppc;
	by ID;
	var PPP_PA_pc PPP_NA_pc PPP_Fatigue_pc PPP_Serenity_pc PPP_PG_pc PPP_Presence_pc PPP_Search_pc 
    PPP_SWLS_pc PPP_Authenticity_pc PPP_Effort_pc;
run;

proc print data = ppppc (obs=10);
run;

*grand mean centering;
*this makes 'ppp_centered' final dataset for mlm across daily logs;

proc standard data = ppppc m=0 out=ppp_centered;
	var IPIP_Open_gc PPP_PA_gc PPP_NA_gc PPP_Fatigue_gc PPP_Serenity_gc PPP_PG_gc PPP_Presence_gc PPP_Search_gc 
    PPP_SWLS_gc PPP_Authenticity_gc PPP_Effort_gc WordCountMean;
run;

proc print data = ppp_centered (obs=10);
run;

****************************
********Authenticity *******
****************************;

proc sort data = ppp_centered out = ppp_centered_sorted;
by Condition;
run;

*Descriptives;
proc means data = wbcMasterDaily_sorted;
var WordCountMean;
run;
proc means data = ppp_centered;
var WordCountMean;
run;

proc means data = wbcMasterDaily_sorted;
by Condition;
var Authentictyppp1 Authenticityppp2 Authenticityppp3;
run;
proc means data = ppp_centered_sorted;
by Condition;
var PPP_Authenticity;
run;

*Model A (Unconditional);

*
Covariance Parameter Estimates 
Cov Parm Subject Estimate StandardError Z Value Pr > Z
UN(1,1) 	ID 	0.7224 		0.1519 		4.76 	<.0001 
Residual   		0.5194 		0.1000 		5.19 	<.0001 
;

*
Solution for Fixed Effects 
Effect		 Estimate  	StandardError 	DF 	t Value 	Pr > |t|
Intercept 	5.4657 			0.1782 		152   30.67 	<.0001 
Time 		-0.1768 		0.1271 		53   -1.39 		0.1699 
;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_Authenticity = Time /ddfm=bw solution;
	random intercept /subject=ID type=un;
run;

*Model B;

*
Covariance Parameter Estimates 
Cov Parm Subject Estimate StandardError Z Value Pr > Z
UN(1,1) 	ID 	0.6854 		0.5207 		1.32 	0.0941 
UN(2,1) 	ID 	0.01470 	0.3180 		0.05 	0.9631 
UN(2,2) 	ID  0			0.2011 		0.00 	0.5000 
;

*
Solution for Fixed Effects 
Effect		 Estimate  	StandardError 	DF 	t Value 	Pr > |t|
Intercept 	5.4674 		0.1780 			152 30.72 		<.0001 
Time 		-0.1785 	0.1276 			53 -1.40 		0.1677 
;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_Authenticity = Time /ddfm=bw solution;
	random intercept Time/subject=ID type=un;
run;

*Model C;

*
Covariance Parameter Estimates 
Cov Parm Subject Estimate StandardError Z Value Pr > Z
UN(1,1) 	ID 	0.7372 		0.1538 		4.79 	<.0001 
Residual   		0.5155 		0.1002 		5.15 	<.0001 
;

*
Solution for Fixed Effects 
Effect		 Estimate  	StandardError 	DF 	t Value 	Pr > |t|
Intercept 		5.6288 		0.2545 		151  22.12 		<.0001 
Time 			-0.2982 	0.1853 		52 	-1.61 		0.1136 
Condition 		-0.3153 	0.3565 		151	 -0.88 		0.3779 
Time*Condition 	0.2288 		0.2542 		52 	0.90 		0.3722 
;
proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_Authenticity = Time Condition Time*Condition/ddfm=bw solution;
	random intercept/subject=ID type=un;
run;

*Model D;

*
Covariance Parameter Estimates 
Cov Parm Subject Estimate StandardError Z Value Pr > Z
UN(1,1) 	ID 		0.6767 	0.1502 		4.51 	<.0001 
Residual   			0.5291 	0.1032 		5.12 	<.0001 
;

*
Solution for Fixed Effects 
Effect				 Estimate  	StandardError 	DF 	t Value 	Pr > |t|
Intercept 			5.6011 		0.2664 			147 	21.03 	<.0001 
Time 				-0.2801 	0.2018 			50 		-1.39 	0.1712 
Condition 			-0.3383 	0.3603 			147 	-0.94 	0.3493 
Time*Condition 		0.1890 		0.2606 			50 		0.73 	0.4717 
WordCountMean 		0.000894 	0.002149 		147 	0.42 	0.6779 
Time*WordCountMean -0.00041 	0.001492 		50 		-0.27 	0.7852 
Condition*WordCountM 0.003869 	0.002071 		147 	1.87 	0.0637 
IPIP_Open_gc 		-0.4390 	0.4063 			147 	-1.08 	0.2817 
Condition*IPIP_Open_ 0.5609 	0.3700 			147 	1.52 	0.1316 
Time*IPIP_Open_gc 	0.07957 	0.2677 			50 		0.30 	0.7675 

;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_Authenticity = Time Condition Time*Condition WordCountMean WordCountMean*Time WordCountMean*Condition
				   IPIP_Open_gc IPIP_Open_gc*Condition IPIP_Open_gc*Time/ddfm=bw solution;
	random intercept/subject=ID type=un;
run;

*
Estimates 
Label `				Estimate 	Standard Error  DF 	t Value Pr > |t| 
Control Intercept 	5.6011 		0.2664 			147 21.03 	<.0001 
Control Slope 		0.000894 	0.002149 		147 0.42 	0.6779 
Openness Intercept 	5.2628 		0.2552 			147 20.62 	<.0001 
Openness Slope 		0.004764 	0.002495 		147 1.91 	0.0582 
;


proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_Authenticity = Time Condition Time*Condition WordCountMean WordCountMean*Time WordCountMean*Condition
				   IPIP_Open_gc IPIP_Open_gc*Condition IPIP_Open_gc*Time/ddfm=bw solution;
	random intercept/subject=ID type=un;
	estimate 'Control Intercept' intercept 1 Condition 0;
	estimate 'Control Slope'  WordCountMean 1 WordCountMean*Condition 0;
	estimate 'Openness Intercept' intercept 1 Condition 1;
	estimate 'Openness Slope' WordCountMean 1 WordCountMean*Condition 1;
run;

data PPPAuthPlot;
do i = -95.84 to 95.84 by 95.84;
Open = 5.60 + .0009*i;
Control = 5.26 + .0048*i;
output; end;
run;
Proc print data=PPPAuthPlot;
run;

*Model E

Cov Parm Subject Estimate Standard Error Z Value Pr > Z 
UN(1,1) ID 		0.6873 	0.1491 		4.61 	<.0001 
Residual   		0.5181 	0.09942 	5.21 	<.0001 


Effect 				Estimate Standard Error DF t Value Pr > |t| 
Intercept 			5.4978 		0.1947 		148 28.24 <.0001 
Time 				-0.1898 	0.1272 		53 -1.49 0.1417 
Condition 			-0.1224 	0.1726 		148 -0.71 0.4795 
WordCountMean 		0.000047 	0.001158 	148 0.04 0.9677 
Condition*WordCountM 0.004896 	0.001982 	148 2.47 0.0147 
IPIP_Open_gc 		-0.06030 	0.1835 		148 -0.33 0.7429 
;
proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_Authenticity = Time Condition WordCountMean WordCountMean*Condition
				   IPIP_Open_gc/ddfm=bw solution;
	random intercept/subject=ID type=un;
run;

****************************
********Effort**************
****************************;

*Descriptives;
proc means data = wbcMasterDaily_sorted;
by Condition;
var Effortppp1 Effortppp2 Effortppp3;
run;
proc means data = ppp_centered_sorted;
by Condition;
var PPP_Effort;
run;

 *Model A (Unconditional);
*
Covariance Parameter Estimates 
Cov Parm Subject Estimate StandardError Z Value Pr > Z
UN(1,1)    ID 		0.5821 	0.1094 			5.32 <.0001 
Residual            0.7890 	0.07750 		10.18 <.0001 
;

*
Solution for Fixed Effects 
Effect		 Estimate  	StandardError 	DF 	t Value 	Pr > |t|
Intercept 	3.4970 			0.08532 	176 40.99 		<.0001 
Time 		-0.2065 		0.06665 	206 -3.10 		0.0022 
;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_Effort = Time /ddfm=bw solution;
	random intercept /subject=ID type=un;
run;

*Model B;

*
Covariance Parameter Estimates 
Cov Parm Subject Estimate StandardError Z Value Pr > Z
UN(1,1) ID 		0.4234 		0.1321 		3.21 	0.0007 
UN(2,1) ID 		0.1198 		0.06873 	1.74 	0.0813 
UN(2,2) ID 		0 . . . 
Residual   		0.7930 		0.07869 	10.08 	<.0001 
;

*
Solution for Fixed Effects 
Effect		 Estimate  	StandardError 	DF 	t Value 	Pr > |t|
Intercept 	3.4971 		0.08011 		176 43.65 	<.0001 
Time 		-0.2045 	0.06834 		206 -2.99 	0.0031 
;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_Effort = Time /ddfm=bw solution;
	random intercept Time/subject=ID type=un;
run;

*Model C;

*
Covariance Parameter Estimates 
Cov Parm Subject Estimate StandardError Z Value Pr > Z
UN(1,1) ID 		0.5871 	0.1105 			5.31 <.0001 
Residual   		0.7920 	0.07799 		10.16 <.0001 
;

*
Solution for Fixed Effects 
Effect		 Estimate  	StandardError 	DF 	t Value 	Pr > |t|
Intercept 	3.4934 			0.1202 		175 29.07 		<.0001 
Time 		-0.1956 		0.09718 	205 -2.01 		0.0454 
Condition 	0.007057 		0.1712 		175 0.04 		0.9672 
Time*Condition -0.02044 	0.1338 		205 -0.15 		0.8787 
;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_Effort = Time Condition Time*Condition/ddfm=bw solution;
	random intercept/subject=ID type=un;
run;

*Model D;

*
Covariance Parameter Estimates 
Cov Parm Subject Estimate StandardError Z Value Pr > Z
UN(1,1) ID 		0.5467 		0.1070 		5.11 <.0001 
Residual   		0.7934 		0.07819 	10.15 <.0001 
;

*
Solution for Fixed Effects 
Effect		 Estimate  	StandardError 	DF 	t Value 	Pr > |t|
Intercept 		3.4906 		0.1190 		171 29.32 		<.0001 
Time 			-0.1887 	0.1000 		203 -1.89 		0.0606 
Condition 		0.05653 	0.1699 		171 0.33 		0.7398 
Time*Condition -0.00306 	0.1348 		203 -0.02 		0.9819 
WordCountMean -0.00063 		0.001074 	171 -0.59 		0.5563 
Time*WordCountMean -0.00010 0.000750 	203 -0.14 		0.8895 
Condition*WordCountM -0.00386 0.001690  171 -2.28 		0.0236 
IPIP_Open_gc 	0.1818 		0.2432 		171 0.75 		0.4557 
Condition*IPIP_Open_ -0.08920 0.3182 	171 -0.28 		0.7795 
Time*IPIP_Open_gc -0.1063 	0.1407 		203 -0.76 		0.4506 
;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_Effort = Time Condition Time*Condition WordCountMean WordCountMean*Time WordCountMean*Condition
				   IPIP_Open_gc IPIP_Open_gc*Condition IPIP_Open_gc*Time/ddfm=bw solution;
	random intercept/subject=ID type=un;
run;

*Model E;

*
Cov Parm Subject Estimate StandardError Z Value Pr > Z 
UN(1,1) ID 		0.5689 		0.1045 		5.45 	<.0001 
Residual   		0.7213 		0.07099 	10.16 	<.0001 
;

*
Effect 					Estimate StandardError DF t Value Pr > |t| 
Intercept 				3.5787 		0.1156 		172 30.96 <.0001 
Time 					-0.9841 	0.1823 		204 -5.40 <.0001 
Condition 				0.07278 	0.1582 		172 0.46 0.6460 
IPIP_Open_gc 			0.06274 	0.1579 		172 0.40 0.6916 
WordCountMean 			-0.00073 	0.000959 	172 -0.76 0.4492 
Condition*WordCountM 	-0.00398 	0.001628 	172 -2.45 0.0155 
Time*Time 				0.4735 		0.1068 		204 4.44 <.0001 
Time*Time*Condition 	-0.02793 	0.06987 	204 -0.40 0.6898 
;
proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_Effort = Time Condition IPIP_Open_gc WordCountMean WordCountMean*Condition
				   Time*Time Time*Time*Condition/ddfm=bw solution;
	random intercept/subject=ID type=un;
run;

*
Control Intercept 3.5819 0.1110 376 32.27 <.0001 
Control Slope -0.00070 0.000778 376 -0.90 0.3668 
Openness Intercept 3.6472 0.1129 376 32.30 <.0001 
Openness Slope -0.00460 0.001099 376 -4.19 <.0001 
;
proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_Effort = Time Condition IPIP_Open_gc WordCountMean WordCountMean*Condition
				   Time*Time Time*Time*Condition/ddfm=bw solution;
	estimate 'Control Intercept' intercept 1 Condition 0;
	estimate 'Control Slope'  WordCountMean 1 WordCountMean*Condition 0;
	estimate 'Openness Intercept' intercept 1 Condition 1;
	estimate 'Openness Slope' WordCountMean 1 WordCountMean*Condition 1;
run;
data PPPEffortPlot;
do i = -95.84 to 95.84 by 95.84;
Open = 3.65 - .005*i;
Control = 3.58 - .0007*i;
output; end;
run;
proc print data = PPPEffortPlot;
run;


****************************
********Affect - PA ********
****************************;

*Descriptives;
proc means data = wbcMasterDaily_sorted;
by Condition;
var PAppp1 PAppp2 PAppp3;
run;
proc means data = ppp_centered_sorted;
by Condition;
var PPP_PA;
run;
*Model A (Unconditional);

*
Covariance Parameter Estimates 
Cov Parm Subject Estimate StandardError Z Value Pr > Z 
UN(1,1)    ID 	0.3129 		0.04972 	6.29 	<.0001 
Residual   		0.2678 		0.02622    10.21 	<.0001 

*
Solution for Fixed Effects 
Effect		 Estimate  	StandardError 	DF 	t Value 	Pr > |t| 
Intercept 	3.1673 		0.05585 		176  56.71		 <.0001 
Time 	   -0.1818 		0.03872 		213  -4.70 		 <.0001 
;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_PA = Time /ddfm=bw solution;
	random intercept /subject=ID type=un;
run;

*Model B;

*
Covariance Parameter Estimates 
Cov Parm Subject Estimate StandardError Z Value Pr > Z 
UN(1,1) 	ID 	0.3505 		0.06504 	5.39 	<.0001 
UN(2,1) 	ID -0.04346 	0.04307 	-1.01 	0.3130 
UN(2,2) 	ID  0.09406 	0.04548 	2.07 	0.0193 
Residual  	    0.1982 		0.03273 	6.06 	<.0001 
;

*
Solution for Fixed Effects 
Effect 		Estimate	 Standard Error	 DF 	t Value	 Pr > |t| 
Intercept 	3.1744 		0.05477 		176 	57.96 	<.0001 
Time 		-0.2061 	0.04363 		213 	-4.72 	<.0001 
;


proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_PA = Time/ddfm=bw solution;
	random intercept Time/subject=ID type=un;
run;

*Model C;

*
Covariance Parameter Estimates 
Cov Parm Subject Estimate StandardError Z Value Pr > Z 
UN(1,1)   ID 	0.3521 		0.06513 	5.41 	<.0001 
UN(2,1)   ID   -0.03566 	0.04275 	-0.83 	0.4042 
UN(2,2)   ID    0.08613 	0.04409 	1.95 	0.0254 
Residual   		0.1971 		0.03225 	6.11 	<.0001 
;

*
Solution for Fixed Effects 
Effect 			Estimate 	Standard Error 	DF 	t Value  Pr > |t| 
Intercept 		3.1959 		0.07688 		175   41.57 	<.0001 
Time 			-0.2952 	0.06148 		212   -4.80 	<.0001 
Condition 		-0.04279 	0.1096 			175   -0.39 	0.6967 
Time*Condition 	0.1748 		0.08586 		212   2.04 		0.0430  
;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_PA = Time Condition Time*Condition/ddfm=bw solution;
	random intercept Time/subject=ID type=un;
run;

*Model D;

*
Covariance Parameter Estimates 
Cov Parm Subject Estimate StandardError Z Value Pr > Z
UN(1,1)   ID 	0.3557 		0.06603 	5.39 	<.0001 
UN(2,1)   ID 	-0.04242 	0.04305 	-0.99 	0.3244 
UN(2,2)   ID 	0.08418 	0.04416 	1.91 	0.0283 
Residual   		0.1968 		0.03221 	6.11 	<.0001 
;

*
Solution for Fixed Effects 
Effect 					Estimate 	Standard Error 	DF 	t Value  Pr > |t|
Intercept 				3.1962 		0.07757 	171 	41.21 	<.0001 
Time 					-0.2981 	0.06193 	210 	-4.81 	<.0001 
Condition 				-0.04949 	0.1108 		171 	-0.45 	0.6558 
Time*Condition 			0.1706 		0.08556 	210 	1.99 	0.0475 
WordCountMean 			0.000395 	0.000708 	171 	0.56 	0.5781 
Time*WordCountMean 		0.000195 	0.000476 	210 	0.41 	0.6830 
Condition*WordCountM 	-0.00043 	0.001141 	171 	-0.37 	0.7095 
IPIP_Open_gc 			-0.1721 	0.1631 		171 	-1.06 	0.2928 
Condition*IPIP_Open_ 	0.4257 		0.2176 		171 	1.96 	0.0520 
Time*IPIP_Open_gc 		0.1410 		0.09025 	210 	1.56 	0.1196 
;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_PA = Time Condition Time*Condition WordCountMean WordCountMean*Time WordCountMean*Condition
				   IPIP_Open_gc IPIP_Open_gc*Condition IPIP_Open_gc*Time/ddfm=bw solution;
	random intercept Time/subject=ID type=un;
run;

*
Label  			Estimate StandardError DF t Value Pr > |t| 
Control Intercept 3.1962 	0.07757    171 41.21 <.0001 
Control Slope 	 -0.1721 	0.1631    171 -1.06 0.2928 
Openness Intercept 3.1468 	0.07914   171 39.76 <.0001 
Openness Slope    0.2536    0.1618    171 1.57 0.1190 

;
proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_PA = Time Condition Time*Condition WordCountMean WordCountMean*Time WordCountMean*Condition
				   IPIP_Open_gc IPIP_Open_gc*Condition IPIP_Open_gc*Time/ddfm=bw solution;
	random intercept Time/subject=ID type=un;
 	estimate 'Control Intercept' intercept 1 Condition 0;
	estimate 'Control Slope'  IPIP_Open_gc 1 IPIP_Open_gc*Condition 0;
	estimate 'Openness Intercept' intercept 1 Condition 1;
	estimate 'Openness Slope' IPIP_Open_gc 1 IPIP_Open_gc*Condition 1;
run;

data PPPPAPlot;
do i = -.90 to .90 by .45;
Open = 3.15 + .25*i;
Control = 3.20 - .25*i;
output; end;
run;
Proc print data=PPPPAPlot;
run;
*
Control Intercept 3.1962 0.07757 171 41.21 <.0001 
Control Slope -0.2981 0.06193 210 -4.81 <.0001 
Openness Intercept 3.1468 0.07914 171 39.76 <.0001 
Openness Slope -0.1275 0.06034 210 -2.11 0.0357 
;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_PA = Time Condition Time*Condition WordCountMean WordCountMean*Time WordCountMean*Condition
				   IPIP_Open_gc IPIP_Open_gc*Condition IPIP_Open_gc*Time/ddfm=bw solution;
	random intercept Time/subject=ID type=un;
 	estimate 'Control Intercept' intercept 1 Condition 0;
	estimate 'Control Slope' Time 1 Time*Condition 0;
	estimate 'Openness Intercept' intercept 1 Condition 1;
	estimate 'Openness Slope' Time 1 Time*Condition 1;
run;
data PPPPAbyCond; 
  do time= 0 to 2;
   Control = 3.20 -.291*time;
   Openness = 3.15 -.128*time;
  output;
  end;
run;
proc print data = PPPPAbyCond;
run;
*Model E

Cov Parm Subject Estimate Standard Error Z Value Pr Z 
UN(1,1) ID 		0.3653 		0.06501 5.62 	<.0001 
UN(2,1) ID 		-0.04958 	0.04185 -1.18 	0.2362 
UN(2,2) ID 		0.08901 	0.04270 2.08 	0.0185 
Residual   		0.1854 		0.03066 6.05 	<.0001 
 

Effect 					Estimate Standard Error DF t Value 	Pr > |t| 
Intercept 				3.2304 		0.07854 	172  41.13 	<.0001 
Time 					-0.6033 	0.1366 		210  -4.42 	<.0001 
Condition 				-0.06141 	0.1123 		172  -0.55 	0.5852 
Time*Condition 			0.2238 		0.1938 		210   1.15 	0.2496 
Time*Time 				0.1927 		0.07700 	210   2.50 	0.0131 
Time*Time*Condition 	-0.03523 	0.1080 		210  -0.33 	0.7446 
WordCountMean 			0.000321 	0.000538 	172   0.60 	0.5522 
IPIP_Open_gc 			-0.08506 	0.1534 		172  -0.55 	0.5799 
Condition*IPIP_Open_ 	0.4116 		0.2111 		172   1.95 	0.0528 
;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_PA = Time Condition Time*Condition Time*Time Time*Time*Condition WordCountMean
		IPIP_Open_gc IPIP_Open_gc*Condition/ddfm=bw solution;
	random intercept Time/subject=ID type=un;
	 	estimate 'Control Intercept' intercept 1 Condition 0;
	estimate 'Control Slope' Time 1 Time*Condition 0;
	estimate 'Openness Intercept' intercept 1 Condition 1;
	estimate 'Openness Slope' Time 1 Time*Condition 1;
run;
*Label 			Estimate Standard Error DF t Value Pr > |t| 
Control Intercept 3.2304 	0.07854 172 41.13 	<.0001 
Control Slope 	-0.6033 	0.1366 	210 -4.42 	<.0001 
Openness Intercept 3.1690 	0.07990 172 39.66 	<.0001 
Openness Slope 	-0.3795 	0.1375 	210 -2.76 	0.0063 ;

data PPPPAPlot;
do i = -.90 to .90 by .45;
Open = 3.17 - .379*i;
Control = 3.23 - .603*i;
output; end;
run;
Proc print data=PPPPAPlot;
run;
****************************
********Affect - NA ********
****************************;

*Descriptives;
proc means data = wbcMasterDaily_sorted;
by Condition;
var NAppp1 NAppp2 NAppp3;
run;
proc means data = ppp_centered_sorted;
by Condition;
var PPP_NA;
run;
*Model A (Unconditional);

*
Covariance Parameter Estimates 
Cov Parm Subject Estimate StandardError Z Value Pr > Z
UN(1,1) 	ID 		0.3202 	 0.04722 	6.78 	<.0001 
Residual  		 	0.2148	 0.02103 	10.21 	<.0001 
;

*
Solution for Fixed Effects 
Effect 		Estimate 	Standard Error 	DF 	t Value 	Pr > |t| 
Intercept 	2.3271 		0.05379 		176   43.26 	<.0001 
Time 		-0.1937 	0.03484 		213   -5.56 	<.0001 
 
;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_NA = Time /ddfm=bw solution;
	random intercept /subject=ID type=un;
run;
*Model B;

*
Covariance Parameter Estimates 
Cov Parm Subject Estimate StandardError Z Value Pr > Z
UN(1,1) 	ID 	0.3629 		0.05803 	6.25 	<.0001 
UN(2,1) 	ID -0.03167 	0.02082 	-1.52	 0.1282 
UN(2,2) 	ID 	0 . . . 
Residual   		0.2140 		0.02077 	10.30 	<.0001 
;

*
Solution for Fixed Effects 
Effect 		Estimate 	Standard Error 	DF 	t Value 	Pr > |t|
Intercept 	2.3252 		0.05592 		176 41.58 		<.0001 
Time 		-0.1892 	0.03407 		213 -5.55 		<.0001 
;

*
Note: not enough info to calculate cov for time so no included as random
in subsequent models;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_NA = Time/ddfm=bw solution;
	random intercept Time/subject=ID type=un;
run;


*Model C;

*
Covariance Parameter Estimates 
Cov Parm Subject Estimate StandardError Z Value Pr > Z
UN(1,1) 	ID 		0.3201	 0.04732 	6.76 	<.0001 
Residual   			0.2147 	 0.02107 	10.19 	<.0001 
;

*
Solution for Fixed Effects 
Effect 			Estimate 	Standard Error 	DF 	t Value 	Pr > |t| 
Intercept 		2.3698 			0.07548 	175 31.40 		<.0001 
Time 			-0.1659 		0.05014 	212 -3.31 		0.0011 
Condition 		-0.08776 		0.1076 		175 -0.82 		0.4158 
Time*Condition -0.05242 		0.06971 	212 -0.75 		0.4529 
 
;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_NA = Time Condition Time*Condition/ddfm=bw solution;
	random intercept/subject=ID type=un;
run;

*Model D;

*Covariance Parameter Estimates 
Cov Parm Subject Estimate StandardError Z Value Pr > Z
UN(1,1) 	ID 		0.3142 	0.04719 	6.66 	<.0001 
Residual   			0.2143 	0.02111 	10.15 	<.0001 
;

*
Solution for Fixed Effects 
Effect 				Estimate 	Standard Error 	DF 	t Value 	Pr > |t| 
Intercept 			2.3817 		0.07547 		171 31.56 		<.0001 
Time 				-0.1837 	0.05136 		210 -3.58 		0.0004 
Condition 			-0.09002 	0.1078 			171 -0.84 		0.4049 
Time*Condition 		-0.04089 	0.06993 		210 -0.58 		0.5594 
WordCountMean 		-0.00028 	0.000691 		171 -0.41 		0.6835 
Time*WordCountMean 	0.000577 	0.000392 		210 1.47 		0.1429 
Condition*WordCountM -0.00111 	0.001119 		171 -0.99 		0.3241 
IPIP_Open_gc		 0.3469 	0.1590 			171 2.18 		0.0305 
Condition*IPIP_Open_ -0.1257 	0.2131 			171 -0.59 		0.5561 
Time*IPIP_Open_gc 	-0.1062 	0.07304 		210 -1.45 		0.1475 
;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_NA = Time Condition Time*Condition WordCountMean WordCountMean*Time WordCountMean*Condition
				   IPIP_Open_gc IPIP_Open_gc*Condition IPIP_Open_gc*Time/ddfm=bw solution;
	random intercept/subject=ID type=un;
run;

*Model E;

*
Cov Parm Subject Estimate Standard Error Z Value Pr > Z 
UN(1,1) ID 		0.3273 		0.04623 	7.08 	<.0001 
Residual   		0.1814 		0.01781 	10.18 	<.0001 
;

*
Solution for Fixed Effects 
Effect 				Estimate Standard Error DF t Value Pr > |t| 
Intercept 			2.4425 		0.07356 	173 33.21 	<.0001 
Time 				-0.7395 	0.09069 	211 -8.15 	<.0001 
Condition 			-0.09727 	0.1025 		173 -0.95 	0.3438 
WordCountMean 		-0.00039 	0.000527 	173 -0.73 	0.4642 
IPIP_Open_gc 		0.2009 		0.1060 		173 1.90 	0.0596 
Time*Time 			0.3385 		0.05287 	211 6.40 	<.0001 
Time*Time*Condition -0.03809 	0.03497 	211 -1.09 	0.2773 

;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_NA = Time Condition WordCountMean IPIP_Open_gc Time*Time Time*Time*Condition
				   IPIP_Open_gc/ddfm=bw solution;
	random intercept/subject=ID type=un;
run;


****************************
********Personal Growth ****
****************************;

*Descriptives;
proc means data = wbcMasterDaily_sorted;
by Condition;
var PGppp1 PGppp2 PGppp3;
run;
proc means data = ppp_centered_sorted;
by Condition;
var PPP_PA;
run;

*Model A (Unconditional);

*
Covariance Parameter Estimates 
Cov Parm Subject Estimate StandardError Z Value Pr > Z
UN(1,1)   ID 	0.1886 		0.02430 	7.76 	<.0001 
Residual   		0.07017 	0.006906 	10.16 	<.0001 
;

*
Solution for Fixed Effects 
Effect 		Estimate 	Standard Error 	DF 	t Value 	Pr > |t| 
Intercept	 4.1146 		0.03770 	176 	109.14 	<.0001 
Time 		 0.05473 		0.02032 	209 	2.69 	0.0076 
;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_PG = Time /ddfm=bw solution;
	random intercept /subject=ID type=un;
run;

*Model B;

*
Covariance Parameter Estimates 
Cov Parm Subject Estimate StandardError Z Value Pr > Z
UN(1,1)    ID 	0.1870 		0.02732 	6.84 	<.0001 
UN(2,1)    ID 	0.001144 	0.01190 	0.10 	0.9234 
UN(2,2)    ID 	0.008689 	0.01021 	0.85 	0.1974 
Residual   		0.06335 	0.009624 	6.58 	<.0001 
;

*
Solution for Fixed Effects 
Effect 		Estimate 	Standard Error 	DF 	t Value 	Pr > |t|
Intercept 	4.1142 		0.03715 		176 110.75 		<.0001 
Time 		0.05580 	0.02135 		209 2.61 		0.0096 
;

*time wont be random in subsequent models;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_PG = Time/ddfm=bw solution;
	random intercept Time /subject=ID type=un;
run;

*Model C;

*
Covariance Parameter Estimates 
Cov Parm Subject Estimate StandardError Z Value Pr > Z
UN(1,1)	 ID 	0.1885 		0.02431 	7.75 	<.0001 
Residual   		0.06992 	0.006889 	10.15 	<.0001 
;

*
Solution for Fixed Effects 
Effect 	 		Estimate 	Standard Error 	DF 	t Value 	Pr > |t| 
Intercept 		4.0645 		0.05288 		175   76.86 	<.0001 
Time 			0.08512 	0.02958 		208   2.88 		0.0044 
Condition 		0.1014 		0.07537 		175   1.34 		0.1804 
Time*Condition -0.05806 	0.04064 		208   -1.43 	0.1546 

;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_PG = Time Condition Time*Condition/ddfm=bw solution;
	random intercept /subject=ID type=un;
run;

*Model D;

*
Covariance Parameter Estimates 
Cov Parm Subject Estimate StandardError Z Value Pr > Z
UN(1,1)	   ID	 0.1417 	0.01956 	7.24 	<.0001 
Residual   		 0.07046 	0.006971 	10.11 	<.0001 
;

*
Solution for Fixed Effects 
Effect 	 		Estimate 	Standard Error 	DF 	t Value 	Pr > |t|
Intercept 			4.0769 		0.04805 	171	 84.85 		<.0001 
Time 				0.08457 	0.03034 	206   2.79 		0.0058 
Condition 			0.05721 	0.06863 	171   0.83 		0.4057 
Time*Condition 		-0.05921 	0.04084 	206  -1.45 		0.1486 
WordCountMean 		0.000493 	0.000442 	171   1.12 		0.2663 
Time*WordCountMean 	-0.00001 	0.000227 	206  -0.05 		0.9575 
Condition*WordCountM 0.000929 	0.000725 	171   1.28 		0.2015 
IPIP_Open_gc 		0.2084 		0.1022 		171   2.04 		0.0431 
Condition*IPIP_Open_ 0.2867 	0.1385 		171   2.07 		0.0400 
Time*IPIP_Open_gc 	0.02035 	0.04254 	206   0.48 		0.6330 

;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_PG = Time Condition Time*Condition WordCountMean WordCountMean*Time WordCountMean*Condition
				   IPIP_Open_gc IPIP_Open_gc*Condition IPIP_Open_gc*Time/ddfm=bw solution;
	random intercept/subject=ID type=un;
run;

*Probing traitopen*condition;

*
Label 				Estimate 	StandardError 		DF 		t Value Pr > |t| 
Control Intercept 	4.0769 		0.04805 			171 	84.85 		<.0001 
Control Slope 		0.2084 		0.1022 				171 	2.04 		0.0431 
Openness Intercept 	4.1341 		0.04899 			171 	84.38 		<.0001 
Openness Slope 		0.4951 		0.1015 				171 	4.88 		<.0001 
;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_PG = Time Condition Time*Condition WordCountMean WordCountMean*Time WordCountMean*Condition
				   IPIP_Open_gc IPIP_Open_gc*Condition IPIP_Open_gc*Time/ddfm=bw solution;
	random intercept/subject=ID type=un;
	estimate 'Control Intercept' intercept 1 Condition 0;
	estimate 'Control Slope'  IPIP_Open_gc 1 IPIP_Open_gc*Condition 0;
	estimate 'Openness Intercept' intercept 1 Condition 1;
	estimate 'Openness Slope' IPIP_Open_gc 1 IPIP_Open_gc*Condition 1;
run;

data PPPPGPlot;
do i = -.90 to .90 by .45;
Open = 4.13 + .50*i;
Control = 4.08 + .21*i;
output; end;
run;
Proc print data=Plot;
run;

*Model E

Cov Parm Subject Estimate Standard Error Z Value Pr Z 
UN(1,1) ID 		0.1452 		0.02303 6.30 	<.0001 
UN(2,1) ID 		-0.00228 	0.01081 -0.21 	0.8327 
UN(2,2) ID 		0.009541 	0.01033 0.92 	0.1779 
Residual   		0.06117 	0.009585 6.38 	<.0001 

Effect 				Estimate Standard Error DF t Value Pr > |t| 
Intercept 			4.0595 		0.04865 	172 83.45 	<.0001 
Time 				0.2627 		0.07990 	206 3.29 	0.0012 
Condition 			0.07491 	0.06956 	172 1.08 	0.2830 
WordCountMean 		0.000816 	0.000343 	172 2.38 	0.0184 
Time*Condition 		-0.1936 	0.1126 		206 -1.72 	0.0872 
Time*Time 			-0.1078 	0.04422 	206 -2.44 	0.0156 
Time*Time*Condition 0.08350 	0.06151 	206 1.36 	0.1761 
IPIP_Open_gc	 	0.2033 		0.09805 	172 2.07 	0.0396 
Condition*IPIP_Open_ 0.3322 	0.1347 		172 2.47 	0.0146 
;


proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_PG = Time Condition WordCountMean Time*Condition Time*Time Time*Time*Condition
				   IPIP_Open_gc IPIP_Open_gc*Condition/ddfm=bw solution;
	random intercept Time/subject=ID type=un;
	run;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_PG = Time Condition WordCountMean Time*Condition Time*Time Time*Time*Condition
				   IPIP_Open_gc IPIP_Open_gc*Condition/ddfm=bw solution;
	random intercept Time/subject=ID type=un;
	estimate 'Control Intercept' intercept 1 Condition 0;
	estimate 'Control Slope'  Time 1 Time*Condition 0;
	estimate 'Openness Intercept' intercept 1 Condition 1;
	estimate 'Openness Slope' Time 1 Time*Condition 1;
run;
*Label 				Estimate Standard Error DF t Value Pr > |t|  
Control Intercept 	4.0596 		0.04809 	172 84.41 	<.0001 
Control Slope 		0.2639 		0.07714 	206 3.42 	0.0008 
Openness Intercept 	4.1345 		0.04892 	172 84.51 	<.0001 
Openness Slope 		0.06999 	0.07652 	206 0.91 	0.3614 
 ;




****************************
********MILQ--Presence *****
****************************;

*Model A (Unconditional);

*
UN(1,1) ID 1.3678 0.1630 8.39 <.0001 
Residual   0.2993 0.02934 10.20 <.0001 
;

*
Solution for Fixed Effects 
Effect    Estimate 	Standard Error	 DF 	t Value 	Pr > |t| 
Intercept 4.4335 0.09616 176 46.11 <.0001 
Time 0.06104 0.04221 209 1.45 0.1496 

;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_Presence = Time /ddfm=bw solution;
	random intercept /subject=ID type=un;
run;

*Model B;

*
UN(1,1) ID 1.3630 0.1744 7.82 <.0001 
UN(2,1) ID 0.003851 0.05160 0.07 0.9405 
UN(2,2) ID 0 . . . 
Residual   0.2993 0.02934 10.20 <.0001 
;

*Intercept 4.4334 0.09602 176 46.17 <.0001 
Time 0.06124 0.04224 209 1.45 0.1486 
;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_Presence = Time /ddfm=bw solution;
	random intercept Time/subject=ID type=un;
run;

*Model C;

*
UN(1,1) ID 1.3747 0.1643 8.37 <.0001 
Residual   0.3007 0.02955 10.18 <.0001 
;

*Intercept 4.4486 0.1353 175 32.89 <.0001 
Time 0.07456 0.06176 208 1.21 0.2287 
Condition -0.03117 0.1928 175 -0.16 0.8718 
Time*Condition -0.02517 0.08479 208 -0.30 0.7668 
;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_Presence = Time Condition Time*Condition/ddfm=bw solution;
	random intercept/subject=ID type=un;
run;

*Model D;

*
UN(1,1) ID 1.3735 0.1662 8.26 <.0001 
Residual   0.3035 0.02996 10.13 <.0001 
;

*
Intercept 4.4265 0.1362 171 32.51 <.0001 
Time 0.07824 0.06365 206 1.23 0.2204 
Condition -0.02645 0.1946 171 -0.14 0.8920 
Time*Condition -0.02863 0.08551 206 -0.33 0.7381 
WordCountMean -0.00077 0.001265 171 -0.61 0.5451 
Time*WordCountMean -0.00003 0.000477 206 -0.06 0.9487 
Condition*WordCountM 0.001837 0.002123 171 0.87 0.3881 
IPIP_Open_gc -0.4289 0.2959 171 -1.45 0.1490 
Condition*IPIP_Open_ 0.5860 0.4077 171 1.44 0.1525 
Time*IPIP_Open_gc -0.01228 0.08901 206 -0.14 0.8904 
;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_Presence = Time Condition Time*Condition WordCountMean WordCountMean*Time WordCountMean*Condition
				   IPIP_Open_gc IPIP_Open_gc*Condition IPIP_Open_gc*Time/ddfm=bw solution;
	random intercept/subject=ID type=un;
run;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_Presence = Time Condition Time*Condition WordCountMean WordCountMean*Time WordCountMean*Condition
				   IPIP_Open_gc IPIP_Open_gc*Condition IPIP_Open_gc*Time/ddfm=bw solution;
	random intercept/subject=ID type=un;
	estimate 'Control Intercept' intercept 1 Condition 0;
	estimate 'Control Slope'  Time 1 Time*Condition 0;
	estimate 'Openness Intercept' intercept 1 Condition 1;
	estimate 'Openness Slope' Time 1 Time*Condition 1;
run;


****************************
********MILQ--Search *******
****************************;

*Model A (Unconditional);

*
UN(1,1) ID 1.2458 0.1527 8.16 <.0001 
Residual   0.3390 0.03343 10.14 <.0001 
;

*
Solution for Fixed Effects 
Effect    Estimate 	Standard Error	 DF 	t Value 	Pr > |t|  
Intercept 5.1342 0.09360 176 54.86 <.0001 
Time -0.09007 0.04494 207 -2.00 0.0463  
;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_Search = Time /ddfm=bw solution;
	random intercept /subject=ID type=un;
run;

*Model B;

*
UN(1,1) ID 1.2412 0.1646 7.54 <.0001 
UN(2,1) ID 0.009120 0.06230 0.15 0.8836 
UN(2,2) ID 0.05232 0.04476 1.17 0.1212 
Residual   0.2967 0.04315 6.87 <.0001 
;

*
Solution for Fixed Effects 
Effect    Estimate 	Standard Error	 DF 	t Value 	Pr > |t| 
Intercept 5.1353 0.09237 176 55.60 <.0001 
Time -0.09487 0.04758 207 -1.99 0.0475 
;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_Search = Time/ddfm=bw solution;
	random intercept Time/subject=ID type=un;
run;
*Model C;

*
UN(1,1) ID 1.2489 0.1536 8.13 <.0001 
Residual   0.3399 0.03360 10.12 <.0001 
;

*
Solution for Fixed Effects 
Effect    		Estimate 	Standard Error	 DF 	t Value 	Pr > |t| 
Intercept 5.0458 0.1315 175 38.37 <.0001 
Time -0.06315 0.06568 206 -0.96 0.3375 
Condition 0.1794 0.1875 175 0.96 0.3400 
Time*Condition -0.05194 0.09018 206 -0.58 0.5653 

;

proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_Search = Time Condition Time*Condition/ddfm=bw solution;
	random intercept /subject=ID type=un;
run;

*Model D;

*
UN(1,1) ID 1.2481 0.1553 8.03 <.0001 
Residual   0.3415 0.03391 10.07 <.0001 
;

*
Intercept 5.0465 0.1323 171 38.13 <.0001 
Time -0.05364 0.06773 204 -0.79 0.4294 
Condition 0.1684 0.1891 171 0.89 0.3745 
Time*Condition -0.04895 0.09078 204 -0.54 0.5904 
WordCountMean 0.000022 0.001228 171 0.02 0.9860 
Time*WordCountMean -0.00036 0.000511 204 -0.70 0.4827 
Condition*WordCountM -0.00083 0.002055 171 -0.40 0.6878 
IPIP_Open_gc 0.09032 0.2863 171 0.32 0.7528 
Condition*IPIP_Open_ 0.5023 0.3935 171 1.28 0.2035 
Time*IPIP_Open_gc -0.04984 0.09462 204 -0.53 0.5990 
;
proc mixed data= ppp_centered method=reml noclprint covtest;
    class ID;
	model PPP_Search = Time Condition Time*Condition WordCountMean WordCountMean*Time WordCountMean*Condition
				   IPIP_Open_gc IPIP_Open_gc*Condition IPIP_Open_gc*Time/ddfm=bw solution;
	random intercept Time/subject=ID type=un;
run;


