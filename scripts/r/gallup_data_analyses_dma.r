## Gallup Microdata Analysis 
## Original: Summer 2019 
## This Version: Winter 2021 

## This file uses the data on Sinclair availabiltiy at the DMA level and Gallup micro-data 
## This file works at the DMA (3-digit zip code) level 
## It generates Table A4 from the appendix 

# ## Read in the Gallup Data 
# files <- dir_ls(path = "Data", regexp = "_DAILY_")
# files
# gallup <- files %>% 
#   map_dfr(read.dta13)  

## Make FIPS code a numeric variable, changes in 2013  
gallup$fips_code <-as.numeric(gallup$fips_code)
gallup$FC <- as.numeric(gallup$FIPS_CODE)
gallup$fips_code <- ifelse(!is.na(gallup$fips_code),gallup$fips_code,gallup$FC)

# ## Do some recoding 
#   gallup <- gallup %>% 
#     mutate(## party ID, values are D/lean D/Ind/lean R/R 
#       pid = ifelse(gallup$PARTY<6,-1*(gallup$PARTY)+6,NA),
#       ## lib-con ideology (higher values are more conservative)
#       libcon = ifelse(gallup$P20<6,-1*(gallup$P20)+6,NA),
#       ## Obama approval: binary (0 = disapprove, 1 = approve)
#       obama_approval = ifelse(gallup$P128 == 1,1,
#                               ifelse(gallup$P128 == 2,0,NA)),
#       ## Trump approval (binary) 
#       trump_approval = ifelse(gallup$P1167 == 1,1,
#                               ifelse(gallup$P1167 == 2,0,NA)),
#       ## Econ (higher values mean better)
#       better_econ = ifelse(WP148<4,-1*WP148+4,NA),
#       ## make date variables into dates 
#       interview_date = ymd(gallup$INT_DATE), 
#       interview_year = year(interview_date), 
#       ## demographics 
#       age = ifelse(WP1220 > 0 & WP1220 < 100, WP1220,NA),
#       over49 = ifelse(age > 49,1,0), 
#       white = ifelse(RACE == 1,1,0),
#       afam =  ifelse(RACE == 3,1,0),
#       female = ifelse(SC7 == 2,1,0),
#       HSorless = ifelse(EDUCATION < 7, 
#                         ifelse(EDUCATION < 4,1,0),NA),
#       baplus = ifelse(EDUCATION < 7, 
#                       ifelse(EDUCATION == 5 | EDUCATION == 6,1,0),NA),
#       lessthan35k = ifelse(INCOME_SUMMARY < 11,
#                            ifelse(INCOME_SUMMARY < 6,1,0),NA),
#       high_inc = ifelse(INCOME_SUMMARY < 11, 
#                         ifelse(INCOME_SUMMARY > 8,1,0),NA),
#       dem = ifelse(pid<3,1,0),
#       rep = ifelse(pid>3,1,0))
#   
#   ## get a day-of-the-week indicator 
#   ## get a month-year indicator (for FEs )
#   gallup <- gallup %>% 
#     mutate(dow = wday(interview_date), 
#            fe_month = floor_date(interview_date, "month"))

## Read in the Sinclair availability data 
sinclair <- read_dta(file = "Data/sinclair_by_county.dta") 
    
## Merge the two together 
  gallup_alt <- left_join(x=gallup,
                          y=sinclair,
                          by=c("fips_code" = "county_fips", 
                               "interview_year" = "year"))
  

## Run the models 
m2 <- felm(pid ~ Sinclair | fips_code + fe_month + dow | 0 | fips_code, 
           data=gallup_alt) 
m3 <- felm(obama_approval ~ Sinclair | fips_code + fe_month + dow | 0 | fips_code, 
           data=gallup_alt)
m4 <- felm(libcon ~ Sinclair | fips_code + fe_month + dow | 0 | fips_code, 
           data=gallup_alt) 
m5 <- felm(trump_approval ~ Sinclair | fips_code + fe_month + dow | 0 | fips_code, 
           data=gallup_alt) 

## Include Controls 
m6 <- felm(trump_approval ~ Sinclair + white + afam + female + baplus + age + high_inc | fips_code + fe_month + dow | 0 | fips_code, 
           data=gallup_alt)
m7 <- felm(pid ~ Sinclair + white + afam + female + baplus + age + high_inc |fips_code + fe_month + dow | 0 | fips_code, 
           data=gallup_alt)
m8 <- felm(obama_approval ~ Sinclair + white + afam + female + baplus + age + high_inc | fips_code + fe_month + dow | 0 | fips_code,  
           data=gallup_alt) 
m9 <- felm(obama_approval ~ Sinclair + pid + white + afam + female + baplus + age + high_inc | fips_code + fe_month + dow | 0 | fips_code, 
           data=gallup_alt) 
m7a <- felm(libcon ~ Sinclair + pid + white + afam + female + baplus + age + high_inc | fips_code + fe_month + dow | 0 | fips_code, 
            data=gallup_alt) 

m10 <- felm(better_econ ~ Sinclair | fips_code + fe_month + dow | 0 | fips_code, 
            data=gallup_alt) 
m11 <- felm(better_econ ~ Sinclair + pid + white + afam + female + baplus + age + high_inc | fips_code + fe_month + dow | 0 | fips_code, 
            data=gallup_alt) 

## Output to a table 
models <- list()
models[["Party ID (1)"]] <- m2 
models[["Party ID (2)"]] <- m7 
models[["Libcon (1)"]] <- m4 
models[["Libcon (2)"]] <- m7a 
models[["Obama Approval (1)"]] <- m3 
models[["Obama Approval (2)"]] <- m9 
models[["Economy Eval (1)"]] <- m10 
models[["Economy Eval (2)"]] <- m11
#models[["Trump Approval (1)"]] <- m5 
#models[["Trump Approval (2)"]] <- m6 
msummary(models,
         coef_map = c("Sinclair" = "Sinclair Availability",
                      "pid" = "Party ID",
                      "afam" = "African-American",
                      "white" = "White",
                      "female"="Female",
                      "baplus"="College Graduate",
                      "age" = "Age",
                      "high_income" = "Top Third, Income"),
         stars = T, 
         output =  "Tables/table_a4.html")
