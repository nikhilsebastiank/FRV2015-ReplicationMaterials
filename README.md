# FRV2015-ReplicationMaterials :mortar_board:
Materials that I have used for the replication of "Farber, H. S., Rothstein, J., &amp; Valletta, R. G. (2015). The effect of extended unemployment insurance benefits: Evidence from the 2012-2013 phase-out. American Economic Review, 105(5), 171-76."

This repository contains scripts and data that I have used for my replication project for the course 'Labor Economics' taught by Professor Pierre Cahuc at Sciences Po during Fall 2021. 

All Stata scripts are published by the authors (https://www.openicpsr.org/openicpsr/project/113408/version/V1/view) and my modifications have mostly been to make some of the code consistent. Additionally, I have added scripts to download CPSB and FRED data that the authors do not provide.

To replicate the main results of the paper, execute the files in the following order: 
(Caution: Please change the working directory to the directory that contains the data)

1. scraper.jl - to download the CPSB data;
2. fred.jl - to download data for Vacancy-Unemployment ratio from the FRED database; (the series is now discontinued and is only available until 2018);
3. FredData.do - To convert the .csv file to .dta and to create variables needed to replicate the paper;
4. Fig1.do - uses the downloaded FRED data and the data constructed by the authors to replicate Figure 1;
5. Fig2.do - uses the data constructed by the authors to replicate Figure 2;
6. regSpec1.do - uses the data constructed by the authors to replicate results using Specification 1. 
7. regSpec2.do - uses the data constructed by the authors to replicate results using Specification 2. 
