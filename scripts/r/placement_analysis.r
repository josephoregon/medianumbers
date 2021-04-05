## Where Does Sinclair Buy Stations? 
## Original Version: Summer 2020 
## Final Version: Winter 2021 

## This file analyzes where Sinclair buys stations 
## It generates Table A2 in the appendix 

## Read in the two datasets, then merge them 
sinclair <- read_csv(file="Data/sinclair_stations_by_county.csv") 
demos <- read_csv(file="Data/county_demos.csv")

## Merge them into one file for analysis 
sinc_with_demos <- left_join(x = sinclair,
                             y = demos,
                             by = c("state" = "State",
                                    "county" = "county"))  

## Look first at 2008 station placement 
## 0/1 have at least 1 station in the county 
sinc_with_demos <- sinc_with_demos %>% 
  mutate(have_at_baseline = ifelse(nsinc08>1,1,0),
         gain_station = ifelse(nsinc18>nsinc08,1,0),
         swing_0812 = prez_pct08 - prez_pct12,
         ## Put median income & total population in thousands of dollars 
         minc_ths = median_income/1000, 
         pop_ths = total_pop/1000)


m0 <- lm_robust(have_at_baseline ~ pct_65plus + pct_white + pct_college + pop_ths + minc_ths,
                data = sinc_with_demos)  
m1 <- lm_robust(have_at_baseline ~ pct_65plus + pct_white + pct_college + pop_ths + minc_ths + prez_pct08,
                data = sinc_with_demos)

## Look at where they buy stations 
m2 <- lm_robust(gain_station ~ pct_65plus + pct_white + pct_college + pop_ths + minc_ths,
                data = sinc_with_demos) 
m3 <- lm_robust(gain_station ~ pct_65plus + pct_white + pct_college + pop_ths + minc_ths + swing_0812,
                data = sinc_with_demos)

## Output to a table 
models <- list()
models[["Pre-2008 (1)"]] <- m0 
models[["Pre-2008 (2)"]] <- m1 
models[["New Acquisitions (1)"]] <- m2 
models[["New Acquisitions (2)"]] <- m3

msummary(models,
         coef_map = c("(Intercept)" = "Constant",
                      "pct_65plus" = "% Seniors",
                      "pct_white" = "% White",
                      "pct_college" = "% College Grad.",
                      "pop_ths" = "Population (Thousands)",
                      "minc_ths"="Median Income (Thousands)",
                      "prez_pct08" = "2008 Democratic Vote Share",
                      "swing_0812" = "Change in 2008-2012 Vote Share"),  
         stars = T, 
         output =  "Tables/table_a2.html")