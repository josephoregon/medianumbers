## Election Data Analysis 
## Sinclair Local Media Project 
## Original Version: Summer 2019 
## This Version: Winter 2021 

## This file analyzes the data on county-level Sinclair availability & presidential elections 
## This generates Table A7 

## Read in the data 
elections <- read_dta(file = "Data/prez_election_data.dta")
sinclair <- read_dta(file = "Data/sinclair_by_county.dta")

### merge in the data on station availability by county 
prez_reg_data <- left_join(x = elections, 
                           y = sinclair, 
                           by = c("fips" = "county_fips", "year" = "year"))


#######################
## Estimate Table A7 ## 
#######################

## make state-year fixed effects 
prez_reg_data <- prez_reg_data %>% 
  mutate(state_year = paste(State,year,sep="-")) 

m1 <- felm(prez_dem_pct ~ Sinclair | state_year + fips,
           data = prez_reg_data)
summary(m1) 

## Compare to within-unit shift in PV 
foo <- prez_reg_data %>% 
  group_by(fips) %>% 
  ## Take out missing values (AK/places w/o counties)
  filter(!is.na(prez_dem_pct)) %>% 
  mutate(range = max(prez_dem_pct, na.rm=T) - min(prez_dem_pct,na.rm=T),
         sd_vs = sd(prez_dem_pct))  
mean(foo$range,na.rm=T) 
mean(foo$sd_vs, na.rm=T) 

