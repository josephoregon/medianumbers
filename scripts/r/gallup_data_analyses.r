## Gallup Microdata Analysis 
## Original: Summer 2019 
## This Version: Winter 2021 

## This file uses the data on Sinclair availabiltiy at the ZTA level and Gallup micro-data 
## This file works at the ZTA (3-digit zip code) level 
## It generates Tables 1 - 3 and Figure 1 from the paper  
## It also generates Tables A5 - A6 and Figure A1 from the supplemental appendix 

## Read in the Gallup Data 
files <- dir_ls(path = "Data", regexp = "_DAILY_")
files
gallup <- files %>% 
  map_dfr(read.dta13)  

## Read in the data on Sinclair availability 
sinc_zta <- read_dta(file = "Data/sinclair_by_zta.dta")

## Do some recoding 
  gallup <- gallup %>% 
    mutate(## party ID, values are D/lean D/Ind/lean R/R 
      pid = ifelse(gallup$PARTY<6,-1*(gallup$PARTY)+6,NA),
      ## lib-con ideology (higher values are more conservative)
      libcon = ifelse(gallup$P20<6,-1*(gallup$P20)+6,NA),
      ## Obama approval: binary (0 = disapprove, 1 = approve)
      obama_approval = ifelse(gallup$P128 == 1,1,
                              ifelse(gallup$P128 == 2,0,NA)),
      ## Trump approval (binary) 
      trump_approval = ifelse(gallup$P1167 == 1,1,
                              ifelse(gallup$P1167 == 2,0,NA)),
      ## Econ (higher values mean better)
      better_econ = ifelse(WP148<4,-1*WP148+4,NA),
      ## make date variables into dates 
      interview_date = ymd(gallup$INT_DATE), 
      interview_year = year(interview_date), 
      ## demographics 
      age = ifelse(WP1220 > 0 & WP1220 < 100, WP1220,NA),
      over49 = ifelse(age > 49,1,0), 
      white = ifelse(RACE == 1,1,0),
      afam =  ifelse(RACE == 3,1,0),
      female = ifelse(SC7 == 2,1,0),
      HSorless = ifelse(EDUCATION < 7, 
                        ifelse(EDUCATION < 4,1,0),NA),
      baplus = ifelse(EDUCATION < 7, 
                      ifelse(EDUCATION == 5 | EDUCATION == 6,1,0),NA),
      lessthan35k = ifelse(INCOME_SUMMARY < 11,
                           ifelse(INCOME_SUMMARY < 6,1,0),NA),
      high_inc = ifelse(INCOME_SUMMARY < 11, 
                        ifelse(INCOME_SUMMARY > 8,1,0),NA),
      dem = ifelse(pid<3,1,0),
      rep = ifelse(pid>3,1,0))
  
  ## get a day-of-the-week indicator 
  ## get a month-year indicator (for FEs )
  gallup <- gallup %>% 
    mutate(dow = wday(interview_date), 
           fe_month = floor_date(interview_date, "month"))

## Make zta code a numeric variable 
gallup$zip <-as.numeric(gallup$ZIPCODE)
## Look at the ZTA 
gallup$zta <- floor(gallup$zip/100) 
    
## Merge the two together 
gallup_alt <- left_join(x=gallup,
                        y=sinc_zta,
                        by=c("zta" = "zta", 
                             "interview_year" = "year"))


######################
## Generate Table 1 ##
######################

m2 <- felm(pid ~ Sinclair | zta + fe_month + dow | 0 | zta, 
           data=gallup_alt) 
m3 <- felm(obama_approval ~ Sinclair | zta + fe_month + dow | 0 | zta, 
           data=gallup_alt)
m4 <- felm(libcon ~ Sinclair | zta + fe_month + dow | 0 | zta, 
           data=gallup_alt) 
m5 <- felm(trump_approval ~ Sinclair | zta + fe_month + dow | 0 | zta, 
           data=gallup_alt) 

## Include Controls 
m6 <- felm(trump_approval ~ Sinclair + white + afam + female + baplus + age + high_inc | zta + fe_month + dow | 0 | zta, 
           data=gallup_alt)
m7 <- felm(pid ~ Sinclair + white + afam + female + baplus + age + high_inc |zta + fe_month + dow | 0 | zta, 
           data=gallup_alt)
m8 <- felm(obama_approval ~ Sinclair + white + afam + female + baplus + age + high_inc | zta + fe_month + dow | 0 | zta,  
           data=gallup_alt) 
m9 <- felm(obama_approval ~ Sinclair + pid + white + afam + female + baplus + age + high_inc | zta + fe_month + dow | 0 | zta, 
           data=gallup_alt) 
m7a <- felm(libcon ~ Sinclair + pid + white + afam + female + baplus + age + high_inc | zta + fe_month + dow | 0 | zta, 
            data=gallup_alt) 

m10 <- felm(better_econ ~ Sinclair | zta + fe_month + dow | 0 | zta, 
            data=gallup_alt) 
m11 <- felm(better_econ ~ Sinclair + pid + white + afam + female + baplus + age + high_inc | zta + fe_month + dow | 0 | zta, 
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
         output =  "Tables/table_one.html")

## What does this effect imply in terms of persuasion? (persausion rate, D-V & K)
## assumptions: 
## 0.9% effect of having access to a Sinclair-owned station 
## In non-Sinclair zips, Obama has about 50% approval (averaging across terms) 
## 28% have access to a Sinclair owned station 
(.009/.28)*(1/.5) 
## Roughly 6% of local news audience is persuaded! 

######################
## Generate Table 2 ## 
######################

## Heterogeneous Effects? 
m10 <- felm(obama_approval ~ Sinclair*over49 + white + afam + female + baplus + high_inc + pid | zta + fe_month + dow | 0 | zta, 
            data=gallup_alt) 
m11 <- felm(obama_approval ~ Sinclair*HSorless + white + afam + female +  age + high_inc + pid | zta + fe_month + dow |0 | zta, 
            data=gallup_alt) 
m12 <- felm(obama_approval ~ Sinclair*lessthan35k + white + afam + female + age + baplus + pid | zta + fe_month + dow | 0 | zta, 
            data=gallup_alt) 

## Output to a table 
models <- list()
models[["Age"]] <- m10  
models[["Education"]] <- m11 
models[["Income"]] <- m12 

msummary(models,
         coef_map = c("Sinclair" = "Sinclair Availability",
                      "pid" = "Party ID",
                      "afam" = "African-American",
                      "white" = "White",
                      "female"="Female",
                      "baplus"="College Graduate",
                      "age" = "Age",
                      "high_income" = "Top Third, Income",
                      "lessthan35k" = "Low-Income",
                      "Sinclair:lessthan35k" = "Sinclair*Low Income",
                      "over49" = "Older Respondent",
                      "HSorless" = "Low Education",
                      "Sinclair:over49" = "Sinclair*Older", 
                      "Sinclair:HSorless" = "Sinclair*Low Education"),
         stars = T, 
         output =  "Tables/table_two.html")

######################
## Generate Table 3 ## 
######################

## Lead/Lag Regression 
m13 <- felm(obama_approval ~ sinc_lag_2 + sinc_lag_1 + Sinclair + sinc_lead_1 + sinc_lead_2 + pid + 
              white + afam + female + baplus + age + high_inc | zta + fe_month + dow | 0 | zta, 
            data=gallup_alt) 

models <- list()
models[["Lead-Lag"]] <- m13

msummary(models,
         coef_map = c("sinc_lag_2" = "Sinclair Availability, t-2",
                      "sinc_lag_1" = "Sinclair Availability, t-1",
                      "Sinclair" = "Sinclair Availability, t",
                      "sinc_lead_1" = "Sinclair Availability, t+1",
                      "sinc_lead_2" = "Sinclair Availability, t+2",
                      "pid" = "Party ID",
                      "afam" = "African-American",
                      "white" = "White",
                      "female"="Female",
                      "baplus"="College Graduate",
                      "age" = "Age",
                      "high_income" = "Top Third, Income"),
         stars = T, 
         output =  "Tables/table_three.html") 


#######################
## Generate Figure 1 ## 
#######################

## make a graph 
## at the ZTA-Month level, plot the average approval for: 
## (1) Never get a Sinclair own-station 
## (2) Get a Sinclair owned station 
## Do for the group that gets bought in 2013 

## Read in the data (formatted for graphing) 
for_graph <- read_dta(file = "Data/for_graph.dta")

g2 <- left_join(x=gallup,
                y=for_graph,
                by=c("zta" = "zta"))

## Do all three outcome variables for 2013 acquisitions 
pid <- g2 %>% 
  filter(!is.na(dk13) & dk13 > -99 & fe_month > "2009-12-01" & fe_month < "2016-01-01") %>% 
  group_by(dk13,fe_month) %>% 
  summarise(avg_pid = mean(pid, na.rm=T)) %>% 
  ggplot(.) + 
  geom_line(aes(x=fe_month, y=avg_pid, lty=as.factor(dk13))) + 
  ggtitle("Partisanship") + 
  theme_bw()+ 
  ylim(2.75,3.25) + 
  xlab("Date of Interview") + 
  ylab("Average PID") + 
  scale_linetype_discrete(name="",
                          labels=c("Always Have","Never Have","New Purchase"))

libcon <- g2 %>% 
  filter(!is.na(dk13) & dk13 > -99 & fe_month > "2009-12-01" & fe_month < "2016-01-01") %>% 
  group_by(dk13,fe_month) %>% 
  summarise(avg_lc = mean(libcon, na.rm=T)) %>% 
  ggplot(.) + 
  geom_line(aes(x=fe_month, y=avg_lc, lty=as.factor(dk13))) + 
  ggtitle("Liberal-Conservative Self ID") + 
  theme_bw()+ 
  ylim(3,3.5) + 
  xlab("Date of Interview") + 
  ylab("Average Lib-Con") 

oa <- g2 %>% 
  filter(!is.na(dk13) & dk13 > -99 & fe_month > "2009-12-01" & fe_month < "2016-01-01") %>% 
  group_by(dk13,fe_month) %>% 
  summarise(avg_oa = mean(obama_approval, na.rm=T)) %>% 
  ggplot(.) + 
  geom_line(aes(x=fe_month, y=avg_oa, lty=as.factor(dk13))) + 
  ggtitle("Presidential Approval") + 
  theme_bw()+ 
  ylim(0.25,0.60) + 
  xlab("Date of Interview") + 
  ylab("Fraction Approving") 

ee <- g2 %>% 
  filter(!is.na(dk13) & dk13 > -99 & fe_month > "2009-12-01" & fe_month < "2016-01-01") %>% 
  group_by(dk13,fe_month) %>% 
  summarise(avg_ee = mean(better_econ, na.rm=T)) %>% 
  ggplot(.) + 
  geom_line(aes(x=fe_month, y=avg_ee, lty=as.factor(dk13))) + 
  ggtitle("Economic Evaluations") + 
  theme_bw()+ 
  ylim(1.15,2.25) + 
  xlab("Date of Interview") + 
  ylab("Average Rating") 

p2 <- ggarrange(pid, libcon, oa, ee,
                ncol=1, nrow = 4,
                common.legend = T, legend = "bottom") 
ggsave(filename = "Figure/Figure1.pdf",
       plot = p2,
       width = 8.5,
       height = 11) 

#######################
## Generate Table A5 ##
#######################

## Read in data on 2013 sales only 
sinclair13 <- read_dta(file="Data/sinclair_by_zta_2013sales_only.dta") 

## Look at just 2013 sales (for a more homogeneous sample) 
## Merge the two together 
gallup_13 <- left_join(x=gallup,
                       y=sinclair13,
                       by=c("zta" = "zta", 
                            "interview_year" = "year"))


m17 <- felm(pid ~ Sinclair + white + afam + female + baplus + age + high_inc |zta + fe_month + dow | 0 | zta, 
            data=gallup_13)
m18 <- felm(obama_approval ~ Sinclair + pid + white + afam + female + baplus + age + high_inc | zta + fe_month + dow | 0 | zta, 
            data=gallup_13) 
m19 <- felm(libcon ~ Sinclair + pid + white + afam + female + baplus + age + high_inc | zta + fe_month + dow | 0 | zta, 
            data=gallup_13) 
m20 <- felm(better_econ ~ Sinclair + pid + white + afam + female + baplus + age + high_inc | zta + fe_month + dow | 0 | zta, 
            data=gallup_13) 


## persuasion rate here: 
## 51% mean approval, 20% have Sinclair access 
(.013/.20)*(1/.51) 

models <- list()
models[["Party ID"]] <- m17
models[["Libcon"]] <- m19
models[["Obama Approval"]] <- m18
models[["Economy Eval"]] <- m20
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
         output =  "Tables/table_a5.html")


#######################
## Generate Table A6 ## 
#######################

## Condition by party ID/ideology  
m14 <- felm(obama_approval ~ Sinclair*pid + white + afam + female + baplus + high_inc + libcon | zta + fe_month + dow | 0 | zta, 
            data=gallup_alt) 
m15 <- felm(obama_approval ~ Sinclair*libcon + white + afam + female + baplus + high_inc + pid | zta + fe_month + dow | 0 | zta, 
            data=gallup_alt) 
## is there an overall effect 
lht(m15, "Sinclair + Sinclair:libcon = 0") ## no effect overall, just via interaction 

## Output to a table 
models <- list()
models[["Party ID"]] <- m14
models[["Ideology"]] <- m15
msummary(models,
         coef_map = c("Sinclair" = "Sinclair Availability",
                      "pid" = "Party ID",
                      "afam" = "African-American",
                      "white" = "White",
                      "female"="Female",
                      "baplus"="College Graduate",
                      "age" = "Age",
                      "high_income" = "Top Third, Income",
                      "libcon" = "Ideology",
                      "Sinclair:pid" = "Sinclair*Party",
                      "Sinclair:libcon" = "Sinclair*Ideology"),
         stars = T, 
         output =  "Tables/table_a6.html")

########################
## Generate Figure A1 ## 
########################

## To generate this figure, uncomment the code below 

# ## starbility 
# perm_controls <- c('party' = 'pid',
#                    'demographics' = 'white + afam + female + baplus + age + high_inc')
# perm_fe_controls <- c('zta FE' = 'zta',
#                       'month FE' = 'fe_month',
#                       'dow FE' = 'dow') 
# pdf(file = "Figure/Figure_a1.pdf")
# stability_plot(data = gallup_alt, 
#                cluster = 'zta',
#                lhs = "obama_approval",
#                rhs = "Sinclair",
#                perm = perm_controls, 
#                perm_fe = perm_fe_controls, 
#                coef_ylim = c(-0.07,0.01),
#                rel_height = 0.65) 
# dev.off() 

