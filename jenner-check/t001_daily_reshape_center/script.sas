/*
  Bundle: t001_daily_reshape_center
  Source: MLM Analysis.sas (daily-logs section), ZvanAllen/Creativity-intervention

  The upstream script begins with:
      proc import datafile='C:\...WBC Dataset V8a.sav' out=wbcMasterDaily dbms=sav replace;
  The .sav is not in the repo (a local Windows path). To let the daily-logs
  reshape/centering/descriptives pipeline run standalone, wbcMasterDaily is
  reconstructed here as a small synthetic dataset with the exact columns the
  DATA step reads (ID, Condition, IPIP_Openness, and the T2-T6 series for
  PA/NA/WordCount/Fatigue/Serenity/Authenticity/Effort). Everything below the
  data block is the author's own code, unchanged.
*/

data wbcMasterDaily;
  input ID Condition IPIP_Openness
        PAT2-PAT6 NAT2-NAT6 WordCountT2-WordCountT6
        FatigueT2-FatigueT6 SerenityT2-SerenityT6
        AuthenticityT2-AuthenticityT6 EffortT2-EffortT6;
  datalines;
1 1 5.52 3.86 4.22 4.15 4.02 4.33 2.36 2.78 2.87 2.32 2.33 91 91 91 92 92 2.47 2.93 2.36 2.34 2.19 4.36 4.4 4.33 4.31 4.17 5.57 5.52 5.89 5.81 5.56 2.71 3.01 2.58 3.02 2.98
2 0 5.05 5.32 5.12 4.88 4.88 5.27 2.43 1.79 1.81 2.28 2.09 87 87 87 86 86 2.2 2.24 2.22 2.44 1.89 5.36 5.09 5.29 5.11 5.67 6.3 6.48 6.0 5.87 5.61 3.63 2.89 3.05 2.97 3.2
3 1 4.93 4.75 5.64 5.58 4.77 5.19 1.55 2.04 1.55 1.44 1.69 152 152 152 151 152 2.44 2.45 2.35 1.91 1.84 3.91 3.64 4.29 4.4 3.81 4.92 4.53 5.19 4.9 5.34 3.38 2.63 2.64 2.77 3.41
4 0 4.25 4.47 4.71 4.8 5.35 4.83 3.04 2.54 2.41 3.07 2.93 84 83 83 83 83 4.22 3.45 3.45 3.73 3.52 5.84 6.0 5.4 6.05 5.9 5.29 5.41 6.06 5.69 5.95 3.16 3.18 3.21 3.2 3.31
5 1 4.66 3.96 3.77 3.51 3.42 3.16 2.85 3.1 2.48 2.27 2.66 121 120 120 120 121 2.76 2.52 2.59 2.32 2.52 4.09 4.37 4.06 3.96 4.27 4.85 4.93 4.8 4.86 4.83 2.94 2.14 2.68 2.32 2.87
6 0 4.07 4.72 5.28 5.51 5.67 4.81 1.86 1.9 1.5 2.2 1.51 123 123 122 123 123 2.66 2.32 2.02 2.26 2.66 5.06 4.62 4.87 4.75 4.76 5.17 4.65 5.1 4.34 4.55 3.42 3.04 2.65 2.9 3.19
7 1 3.65 4.48 5.03 4.7 4.61 4.61 2.45 2.79 2.8 3.34 2.47 98 98 98 98 98 2.84 2.13 2.91 2.84 2.32 5.13 4.58 5.09 5.24 4.72 6.04 6.22 6.34 6.2 6.27 3.7 3.43 3.94 3.53 4.0
8 0 5.9 4.97 4.73 4.75 5.4 5.43 2.57 3.04 2.63 2.73 2.23 135 136 136 136 135 3.12 3.28 3.58 3.51 3.2 5.56 5.45 4.68 5.29 4.63 5.33 5.99 6.17 5.52 6.09 3.55 2.81 2.6 2.91 2.82
9 1 4.34 4.46 4.86 4.89 4.44 5.08 1.48 2.05 1.4 1.99 1.17 94 94 94 94 95 2.58 3.14 3.03 2.8 2.43 4.73 4.82 5.29 4.74 5.31 5.08 4.35 4.88 4.36 5.14 3.79 3.51 4.04 4.2 4.36
10 0 5.47 4.69 4.68 4.58 4.84 5.31 2.82 2.72 2.43 2.57 2.75 126 126 127 126 127 2.27 2.05 2.54 1.91 2.73 5.51 4.98 4.65 5.34 5.01 5.79 6.19 6.42 6.22 6.38 3.27 2.87 3.03 3.36 2.84
11 1 2.56 3.7 3.98 3.82 3.58 4.48 3.3 3.27 3.21 2.78 3.28 100 101 100 100 100 2.56 2.46 1.93 2.15 2.11 4.83 4.89 4.12 4.08 4.88 6.43 5.72 6.23 5.7 5.71 2.4 2.02 2.26 2.85 2.58
12 0 3.22 4.49 4.49 4.44 4.6 3.82 1.39 1.68 2.02 1.53 2.09 143 144 144 143 144 2.86 2.4 2.39 2.79 2.46 5.31 4.92 5.45 5.32 5.7 5.74 6.01 5.7 5.96 5.98 1.94 2.04 2.71 2.55 2.76
13 1 2.74 4.92 5.79 5.52 5.58 4.89 1.72 1 1.05 1 1.21 119 118 119 119 119 3.55 3.33 3.94 3.4 3.68 5.35 5.35 5.47 5.51 5.35 4.3 4.73 4.82 4.81 4.32 2.28 2.61 2.82 3.0 2.92
14 0 4.99 4.43 4.71 4.37 4.13 4.32 1.95 1.68 2.06 1.55 2.09 157 157 157 157 158 2.5 2.63 2.38 2.08 1.79 5.39 5.68 5.78 5.77 5.7 6.54 5.95 5.85 6.51 6.31 3.28 3.42 2.76 2.8 3.29
15 1 3.03 3.79 3.88 3.74 4.06 3.85 1.61 2.04 2.1 1.57 2.3 117 117 117 117 117 2.78 2.03 2.57 2.46 2.7 4.55 4.55 4.43 5.22 5.26 5.22 5.53 5.61 5.71 5.27 2.41 1.97 2.25 2.09 2.45
16 0 5.21 4.29 3.63 4.08 3.46 4.26 2.0 1.86 1.85 1.62 1.6 137 137 137 137 137 3.04 3.34 2.69 2.97 2.84 5.72 5.37 4.99 5.51 5.02 5.19 5.32 5.25 5.02 5.47 3.5 4.27 3.98 3.95 3.54
17 1 5.64 3.94 4.29 4.36 3.63 3.67 2.03 1.58 1.96 2.13 1.7 136 137 137 137 137 2.7 2.9 2.52 3.0 2.78 4.07 4.28 4.02 3.81 4.1 6.01 6.21 5.74 5.42 5.98 2.69 2.37 2.66 2.13 2.86
18 0 3.42 4.31 4.42 5.15 4.56 4.6 2.39 2.81 2.16 2.4 2.18 89 90 89 89 89 2.1 1.91 2.05 2.31 2.08 5.79 6.01 6.08 5.25 5.77 4.63 4.73 4.55 4.72 4.82 2.26 2.9 2.67 2.63 2.88
19 1 3.84 4.5 4.99 5.07 5.11 5.23 1.65 1.15 1.53 1.53 1.42 97 97 98 98 97 2.79 2.79 2.73 3.01 2.91 5.37 5.49 5.67 5.81 5.28 6.07 6.04 5.91 5.39 5.3 2.82 2.75 2.35 2.85 2.86
20 0 5.84 4.94 5.05 5.05 4.87 5.09 3.01 2.82 2.78 2.49 3.2 151 150 150 150 150 3.15 2.51 3.27 2.9 2.55 4.55 4.16 5.0 4.24 5.05 6.21 5.83 5.99 6.19 6.47 3.87 3.59 3.35 3.81 4.01
;
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

*person mean centering;

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

*Descriptives;
proc means data = daily_centered;
var IPIP_Openness;
run;
