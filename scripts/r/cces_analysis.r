## Analysis of the CCES Cumulative File 
## Sinclair Project 
## Original Version: Summer 2020 
## Final Version: Winter 2021 

## This analyzes the CCES data 
## It produces Tables 4 and 5 in the paper 

## Read in the CCES Data 
cces <- readRDS(file = "Data/cumulative_2006_2018.Rds")

## vote choice (presidential) & partisanship 
cces <- cces %>% 
  mutate(partyid = ifelse(pid7<8,pid7,NA),
         dem = ifelse(partyid < 4,1,0),
         rep = ifelse(partyid > 4,1,0),
         ## higher values mean approval 
         approve_pres = ifelse(approval_pres < 5, (-1*approval_pres)+5,NA),
         ## libcon self ID 
         libcon = ifelse(cces$ideo5 == "Very Liberal",1,
                         ifelse(cces$ideo5 == "Liberal",2,
                                ifelse(cces$ideo5 == "Moderate",3,
                                       ifelse(cces$ideo5 == "Conservative",4,
                                              ifelse(cces$ideo5 == "Very Conservative",5,NA))))), 
         ## pool across years, 1 = vote Dem, 0 = vote Rep, NA = not voted or other 
         dem_vote08 = ifelse(year == 2008,
                            ifelse(voted_pres_08 == "Barack Obama (Democratic)",1,
                                    ifelse(voted_pres_08 == "John McCain (Republican)",0,NA)),NA),
         dem_vote12 = ifelse(year == 2012, 
                            ifelse(voted_pres_12 == "Barack Obama",1,
                                    ifelse(voted_pres_12 == "Mitt Romney",0,NA)),NA),
         dem_vote16 = ifelse(year == 2016,
                            ifelse(voted_pres_16 == "Hilary Clinton",1,
                                  ifelse(voted_pres_16 == "Donald Trump",0,NA)),NA),
         dem_vote = ifelse(!is.na(dem_vote08),dem_vote08,
                           ifelse(!is.na(dem_vote12),dem_vote12,
                                  ifelse(!is.na(dem_vote16),dem_vote16,NA))),
         fips = as.numeric(county_fips), 
         zta = floor(as.numeric(zipcode)/100),
         ## demographics 
         female = ifelse(!is.na(gender),
                         ifelse(gender == 2,1,0)),
         baplus = ifelse(educ == 5 | educ == 6,1,0), 
         afam = ifelse(race == 2,1,0),
         over100k = ifelse(faminc == "100k - 120k" | faminc == "120k - 150k" | faminc == "150k+",1,0),
         over100k = ifelse(faminc == "Prefer not to say" | faminc == "Skipped",NA,over100k)) 

## For MC Approval 
## Need to get member partisanship (embedded in name) 
cces$mc_is_rep <- str_detect(cces$rep_current,"(R)")
cces$mc_is_rep <- as.numeric(cces$mc_is_rep) 
cces$ar <- as.numeric(cces$approval_rep)
cces$mc_approval <- ifelse(cces$ar<5,(-1*cces$ar)+5,NA) 
cces$mc_approval_binary <- ifelse(cces$mc_approval>2,1,0)

## House Vote Choice 
cces$dem_house_vote <- ifelse(cces$voted_rep=="[Democrat / Candidate 1]",1,
                          ifelse(cces$voted_rep=="[Republican / Candidate 2]",0,NA))

## Senate/gov vote choice 
cces$dem_senate_vote <- ifelse(cces$voted_sen=="[Democrat / Candidate 1]",1,
                              ifelse(cces$voted_sen=="[Republican / Candidate 2]",0,NA))
cces$dem_gov_vote <- ifelse(cces$voted_gov=="[Democrat / Candidate 1]",1,
                              ifelse(cces$voted_gov=="[Republican / Candidate 2]",0,NA))

## economic evaluations (higher = better)
cces$better_econ <- ifelse(cces$economy_retro<6,(-1*cces$economy_retro)+6,NA) 

## Senator approval  
## Need to get member partisanship (embedded in name) 
cces$s1_is_rep <- str_detect(cces$sen1_current,"(R)")
cces$s1_is_rep <- as.numeric(cces$s1_is_rep) 
cces$s1r <- as.numeric(cces$approval_sen1)
cces$s1r_approval <- ifelse(cces$s1r<5,(-1*cces$s1r)+5,NA) 
cces$s2_is_rep <- str_detect(cces$sen2_current,"(R)")
cces$s2_is_rep <- as.numeric(cces$s2_is_rep) 
cces$s2r <- as.numeric(cces$approval_sen2)
cces$s2r_approval <- ifelse(cces$s2r<5,(-1*cces$s2r)+5,NA) 

## just reduce down to the key variables 
## otherwise, you get a weird labelling error (seems to be endemic to the CCES itself)
for_reg <- cbind(cces$dem_vote,
                 cces$year, 
                 #cces$zipcode,
                 cces$zta,
                 cces$partyid,
                 cces$libcon,
                 cces$approve_pres,
                 cces$female,
                 cces$baplus,
                 cces$afam,
                 cces$over100k,
                 cces$dem,
                 cces$rep,
                 cces$better_econ,
                 cces$dem_house_vote,
                 cces$dem_senate_vote,
                 cces$dem_gov_vote,
                 cces$mc_is_rep,
                 cces$mc_approval,
                 cces$approval_sen1,
                 cces$approval_sen2, 
                 cces$s1_is_rep,
                 cces$s2_is_rep)
colnames(for_reg) <- c("dem_vote","year","zta","partyid","libcon",
                       "approve_pres","female","baplus","afam","over100k","dem","rep",
                       "better_econ","dem_house_vote","dem_senate_vote","dem_gov_vote",
                       "mc_is_rep","mc_approval","approval_sen1","approval_sen2",
                       "s1_is_rep","s2_is_rep")
for_reg <- as_tibble(for_reg)
for_reg <- for_reg %>% 
  mutate(zta = as.numeric(zta),
         partyid = as.numeric(partyid),
         libcon = as.numeric(libcon),
         approve_pres = as.numeric(approve_pres),
         female = as.numeric(female),
         baplus = as.numeric(baplus),
         afam = as.numeric(afam),
         over100k = as.numeric(over100k),
         year = as.numeric(year))

## Read in the data on Sinclair availability 
sinc_zta <- read_dta(file = "Data/sinclair_by_zta.dta")

## Merge in the data on Sinclair availability 
cces_reg_data <- left_join(x = for_reg, 
                           y = sinc_zta, 
                           by = c("zta" = "zta", "year" = "year"))

## Presidential Approval? 
m1a <- felm(approve_pres ~ Sinclair | zta + year | 0 | zta,
           subset = year < 2017,
           data = cces_reg_data) 
m1b <- felm(approve_pres ~ Sinclair | zta + year | 0 | zta,
            subset = year > 2016,
            data = cces_reg_data) 
## not enough data to find a Trump effect 

## Partisanship or lib-con self ID? 
m2 <- felm(partyid ~ Sinclair | zta + year | 0 | zta,
             data = cces_reg_data) 
m3 <- felm(libcon ~ Sinclair | zta + year | 0 | zta,
           data = cces_reg_data) 
## no effects 

## models w/ controls 
m5 <- felm(approve_pres ~ Sinclair + female + baplus + afam + over100k + partyid | zta + year | 0 | zta, 
           subset = year < 2017, 
           data = cces_reg_data)  
m6 <- felm(partyid ~ Sinclair + female + baplus + afam + over100k  | zta + year | 0 | zta, 
           data = cces_reg_data) 
m7 <- felm(libcon ~ Sinclair + female + baplus + afam + over100k + partyid | zta + year | 0 | zta, 
           data = cces_reg_data) 
## only real effect is on presidential approval (fragile effect on vote choice)
## effect size is about 75% the effect of gender 

## Economy? 
m8 <-  felm(better_econ ~ Sinclair | zta + year | 0 | zta, 
            subset = year < 2017, 
            data = cces_reg_data)  
m9 <-  felm(better_econ ~ Sinclair + female + baplus + afam + over100k + partyid | zta + year | 0 | zta, 
            subset = year < 2017, 
            data = cces_reg_data) 
## no effect 

## MC Approval? 
m11 <-  felm(mc_approval ~ Sinclair + female + baplus + afam + over100k + partyid | zta + year | 0 | zta, 
             subset = mc_is_rep == 0,
             data = cces_reg_data)  
m12 <-  felm(mc_approval ~ Sinclair + female + baplus + afam + over100k + partyid | zta + year | 0 | zta, 
             subset = mc_is_rep == 1,
             data = cces_reg_data)  
## no effect 

## Senate Approval? 
m21 <-  felm(approval_sen2 ~ Sinclair + female + baplus + afam + over100k + partyid | zta + year | 0 | zta, 
             subset = s2_is_rep == 0,
             data = cces_reg_data)
m22 <-  felm(approval_sen2 ~ Sinclair + female + baplus + afam + over100k + partyid | zta + year | 0 | zta, 
             subset = s2_is_rep == 1,
             data = cces_reg_data) 
## effects are super weird, no consistency in party/name match 

## Pres/House Vote Choice? 
m13 <-  felm(dem_vote ~ Sinclair | zta + year | 0 | zta, 
             data = cces_reg_data)  
m14 <-  felm(dem_vote ~ Sinclair + female + baplus + afam + over100k + partyid | zta + year | 0 | zta, 
             data = cces_reg_data)  
m15 <-  felm(dem_house_vote ~ Sinclair | zta + year | 0 | zta,
             data = cces_reg_data)  
m16 <-  felm(dem_house_vote ~ Sinclair + female + baplus + afam + over100k + partyid | zta + year | 0 | zta, 
             data = cces_reg_data)
m17 <-  felm(dem_senate_vote ~ Sinclair | zta + year | 0 | zta,
             data = cces_reg_data)  
m18 <-  felm(dem_senate_vote ~ Sinclair + female + baplus + afam + over100k + partyid | zta + year | 0 | zta, 
             data = cces_reg_data)
m19 <-  felm(dem_gov_vote ~ Sinclair | zta + year | 0 | zta,
             data = cces_reg_data)  
m20 <-  felm(dem_gov_vote ~ Sinclair + female + baplus + afam + over100k + partyid | zta + year | 0 | zta, 
             data = cces_reg_data)

## Persuasion Rate: presidential vote choice 
## 1% effect on vote choice 
## 52% vote for Dem candidate in non-Sinclair zips 
## 28% have access to a Sinclair-owned station 
(.01/.28)*(1/.51) 
## persuasion rate of 7 percent 

######################
## Generate Table 4 ##
######################

## Output to two table 
models <- list()
models[["Party ID (1)"]] <- m2 
models[["Party ID (2)"]] <- m6 
models[["Lib-Con Self ID (1)"]] <- m3 
models[["Lib-Con Self ID (2)"]] <- m7 
models[["Obama Approval (1)"]] <- m1a
models[["Obama Approval (2)"]] <- m5 
models[["Presidential Vote (1)"]] <- m13
models[["Presidential Vote (2)"]] <- m14 
models[["Economy Eval (1)"]] <- m8
models[["Economy Eval (2)"]] <- m9 

msummary(models,
         coef_map = c("Sinclair" = "Sinclair Availability", 
                      "female" = "Female",
                      "baplus" = "College Graduate",
                      "afam" = "African-American",
                      "over100k" = "High Income",
                      "partyid" = "Party ID"), 
         stars = T, 
         output =  "Tables/table_four.html")

######################
## Generate Table 5 ##
######################

## Sub-national politics table 
models <- list()
models[["House Vote (1)"]] <- m15
models[["House Vote (2)"]] <- m16 
models[["Approval, Dem MC"]] <- m11
models[["Approval, Rep MC"]] <- m12 
models[["Senate Vote (1)"]] <- m17
models[["Senate Vote (2)"]] <- m18 
models[["Governor Vote (1)"]] <- m19
models[["Governor Vote (2)"]] <- m20 
msummary(models,
         coef_map = c("Sinclair" = "Sinclair Availability", 
                      "female" = "Female",
                      "baplus" = "College Graduate",
                      "afam" = "African-American",
                      "over100k" = "High Income",
                      "partyid" = "Party ID"), 
         stars = T, 
         output =  "Tables/table_five.html")

