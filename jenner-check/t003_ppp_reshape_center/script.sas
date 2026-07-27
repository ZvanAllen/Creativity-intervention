/*
  Bundle: t003_ppp_reshape_center
  Source: MLM Analysis.sas (Pretest/Posttest/Posttest section), ZvanAllen/Creativity-intervention

  The pre/post/post analysis reads a second local file:
      proc import datafile='...WBC Dataset V8b.sav' out=wbcMasterPPP dbms=sav replace;
  Not in the repo. wbcMasterPPP is reconstructed here with the exact columns the
  ppp reshape reads (ID, Condition, IPIP_Openness, WordCountMean, and the ppp1-ppp3
  series for PA/NA/Fatigue/Serenity/PG/Presence/Search/SWLS/MILQ/Authenticity/Effort).
  The wide->long reshape and the pc/gc centering below are the author's own.
*/

data wbcMasterPPP;
  input ID Condition IPIP_Openness WordCountMean
        PAppp1-PAppp3 NAppp1-NAppp3 Fatigueppp1-Fatigueppp3
        Serenityppp1-Serenityppp3 PGppp1-PGppp3 Presenceppp1-Presenceppp3
        Searchppp1-Searchppp3 SWLSppp1-SWLSppp3 MILQppp1-MILQppp3
        Authenticityppp1-Authenticityppp3 Effortppp1-Effortppp3;
  datalines;
1 1 4.59 126.8 4.19 3.79 3.72 1.38 1.57 1.41 2.83 2.53 3.08 5.59 5.5 6.1 3.7 3.15 3.38 4.83 4.74 4.16 2.83 3.22 2.72 3.9 3.98 3.79 5.56 5.78 5.53 5.76 5.28 5.33 4.14 4.45 3.85
2 0 3.18 179.7 3.79 4.04 3.44 1.96 1.78 1.97 2.67 2.82 3.29 4.51 4.6 5.02 4.66 4.11 4.47 4.02 4.06 3.93 2.92 3.37 3.02 3.82 3.78 4.35 4.23 4.4 3.92 4.3 5.0 4.48 2.66 2.88 2.2
3 1 2.76 167.0 4.91 5.65 5.61 2.14 1.83 2.19 2.3 2.35 2.81 4.4 4.39 5.28 3.54 3.09 3.32 3.97 4.5 4.38 3.44 3.33 3.47 4.75 5.06 5.09 5.46 5.98 5.49 6.17 5.29 5.69 4.02 4.37 4.05
4 0 5.92 190.6 5.49 5.56 5.52 1.88 1.99 1.31 2.95 3.64 3.66 5.16 5.51 4.99 3.6 3.38 3.39 4.73 5.12 4.87 3.75 3.74 3.11 5.28 4.83 4.69 5.58 6.07 5.22 4.99 4.24 4.52 3.06 2.6 2.84
5 1 5.86 84.8 3.65 4.0 3.95 1.93 1.96 1.65 3.17 2.53 2.91 5.39 5.83 5.61 3.76 4.37 4.68 4.88 5.07 5.13 4.81 4.52 4.31 5.53 5.54 5.91 5.43 5.57 5.26 5.5 4.89 5.76 4.42 4.4 3.96
6 0 4.8 135.0 4.48 4.16 4.49 1.76 1.78 1.92 4.09 4.14 4.07 5.47 5.27 5.07 4.5 4.28 4.89 4.82 4.68 4.61 3.83 3.7 3.33 4.57 4.36 4.84 3.99 3.86 3.57 5.81 6.2 6.29 2.92 2.73 2.19
7 1 5.93 165.6 4.45 5.15 4.33 2.93 2.75 3.15 2.69 2.47 3.1 3.85 3.71 3.72 2.79 3.47 3.26 5.1 4.38 4.47 3.41 3.48 4.21 4.68 4.41 4.15 4.21 4.41 3.97 4.87 5.67 4.97 3.91 4.11 4.25
8 0 3.53 154.1 5.03 5.52 5.36 2.85 2.88 2.6 3.38 3.27 4.01 5.89 5.19 5.15 4.18 4.37 4.36 5.55 5.47 5.22 2.77 2.69 2.7 5.38 4.91 5.06 5.67 5.4 4.7 4.15 4.75 5.11 3.52 3.75 3.58
9 1 3.11 157.1 5.54 5.35 5.06 2.77 2.3 2.68 3.92 3.95 3.24 3.96 4.17 4.04 4.77 4.52 4.39 3.73 3.63 4.23 3.08 3.34 2.69 4.44 4.15 4.78 4.21 4.22 4.44 5.54 5.76 5.35 2.44 2.98 2.68
10 0 5.1 120.9 4.01 4.31 4.55 1.41 1.7 1.55 2.78 3.36 2.7 5.06 5.46 5.44 4.66 4.47 4.95 3.49 3.91 4.29 3.99 3.9 3.6 5.12 5.62 5.16 4.3 4.44 3.94 4.5 4.14 4.56 3.6 3.43 3.55
11 1 3.78 101.7 4.16 4.09 4.08 1.98 2.05 1.57 3.62 3.34 3.58 5.2 5.49 4.9 3.49 3.62 2.74 6.0 5.19 5.6 2.68 2.69 2.59 5.72 5.62 5.89 3.87 3.98 4.25 4.95 5.38 5.03 4.34 4.28 3.48
12 0 2.62 165.9 4.24 4.15 4.37 2.75 2.72 2.25 3.4 3.24 3.85 5.24 5.68 5.44 4.27 4.04 3.9 5.19 4.52 4.93 2.99 2.64 3.2 5.3 5.52 5.65 5.78 5.38 6.01 5.33 5.6 5.42 3.12 2.95 2.78
13 1 2.64 158.9 4.65 4.22 4.56 3.12 3.11 2.78 2.95 2.52 2.19 4.19 3.82 4.24 4.72 4.63 4.44 4.47 4.26 4.47 4.11 3.63 4.38 5.6 6.06 5.1 4.93 4.64 4.85 5.14 5.38 5.26 3.48 3.65 3.54
14 0 4.41 127.6 3.53 3.54 4.26 1.95 1.94 1.53 2.04 2.34 2.71 5.06 4.72 4.84 3.62 4.11 4.36 4.47 4.64 3.96 2.63 2.51 2.53 4.27 4.39 4.85 4.45 4.05 3.66 5.42 5.46 5.0 3.79 4.37 4.36
15 1 5.04 118.2 4.01 3.94 3.88 2.37 2.52 1.71 3.34 2.61 2.98 4.55 4.42 4.28 4.47 4.09 4.34 4.07 4.12 4.27 3.9 3.43 3.91 4.99 5.43 4.87 3.92 4.07 4.25 6.08 6.12 5.67 2.48 2.83 2.59
16 0 5.73 214.8 3.53 3.67 3.87 3.21 2.68 2.48 3.87 3.09 3.22 5.16 5.1 5.18 4.35 4.44 4.27 5.14 4.83 4.74 4.27 4.15 4.16 3.36 3.53 3.17 4.9 5.31 4.96 4.89 4.68 5.14 3.02 3.37 3.77
17 1 2.92 130.4 4.9 4.43 4.2 1.49 1.53 2.06 3.91 3.67 3.83 4.02 4.75 3.88 3.62 4.44 4.43 3.95 4.3 3.8 3.84 4.39 3.84 5.14 5.19 5.5 4.33 4.84 4.6 5.73 6.22 6.45 3.2 2.76 2.76
18 0 4.97 104.4 3.59 3.57 3.86 2.19 2.51 2.73 3.79 3.26 3.56 5.41 5.06 5.12 2.68 3.37 3.56 3.92 3.52 3.14 2.9 3.04 2.95 3.65 3.79 3.43 5.36 5.04 4.62 5.35 4.88 5.26 2.72 2.57 2.24
19 1 3.67 193.5 5.36 4.8 5.45 2.74 2.29 2.48 3.33 3.42 3.82 5.69 5.18 5.26 5.06 4.75 4.45 4.27 3.83 3.91 3.44 2.88 3.22 5.28 5.58 5.82 4.28 4.54 4.25 6.08 5.87 5.96 4.26 4.01 3.72
20 0 4.43 64.1 5.23 4.74 4.76 2.01 2.23 2.38 3.75 2.84 3.05 4.79 4.63 4.18 4.08 3.63 4.05 4.17 3.41 3.99 3.93 3.78 3.25 3.42 3.62 3.86 4.61 4.69 4.25 4.63 4.6 4.98 2.68 2.28 2.34
;
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

*Descriptives;
proc means data = ppp_centered;
var WordCountMean;
run;
