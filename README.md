# FRV2015-ReplicationMaterials :mortar_board:
Materials that I have used for the replication of "Farber, H. S., Rothstein, J., &amp; Valletta, R. G. (2015). The effect of extended unemployment insurance benefits: Evidence from the 2012-2013 phase-out. American Economic Review, 105(5), 171-76."

This repository contains scripts and data that I have used for my replication project for the course 'Labor Economics' taught by Professor Pierre Cahuc at Sciences Po during Fall 2021. 

All Stata scripts are published by the authors (https://www.openicpsr.org/openicpsr/project/113408/version/V1/view) and my modifications have mostly been to make some of the code consistent. Additionally, I have added scripts to download CPSB and FRED data that the authors do not provide.

To replicate the main results of the paper, execute the files in the following order: 
(Caution: Please change the working directory to the directory that contains the data)

1. scraper.jl - to download the CPSB data and data for Vacancy-Unemployment ratio from the FRED database;
2. FredData.do - To convert the .csv file to .dta and to create variables needed to replicate the paper;
3. Fig1.do - uses the downloaded FRED data and the data constructed by the authors to replicate Figure 1;
4. Fig2.do - uses the data constructed by the authors to replicate Figure 2;
5. regSpec1.do - uses the data constructed by the authors to replicate results using Specification 1. 
6. regSpec2.do - uses the data constructed by the authors to replicate results using Specification 2. 

Feel free to write to me at nikhil.sebastian@sciencespo.fr for further clarifications/questions.
