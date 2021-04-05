## Sinclair Local News Project 
## Replication Archive Master File 
## Winter 2021 

## This file runs the analysis of Sinclair 
## It loads libraries, sets the working directory, and pulls in all files 

## Load necessary libraries 
library(janitor) 
library(tidyverse)
library(lubridate)
library(fs)
library(purrr)
library(lfe)
library(haven)
library(readstata13)
library(starbility)
library(modelsummary)
library(ggpubr)
library(car)
library(estimatr) 

## Set the working directory 
## You must set this to the correct location on your machine 
#setwd("")

## Run the analyses with the Gallup Data 
source("gallup_data_analyses.r") 

## Run the analyses with CCES Data 
source("cces_analysis.r") 

## Run some supplemental analyses for the appendix 
source("table_a1.r") 
source("placement_analysis.r") 
source("gallup_data_analyses_zip5.r") 
source("gallup_data_analyses_dma.r") 
source("election_analysis.r") 
