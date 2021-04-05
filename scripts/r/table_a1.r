## Sinclair Local News Project 
## Original Version: Summer 2019 
## Final Version: Winter 2021 

## This replicates Table A1 from the appendix 

## Which stations does Sinclair own? 
## Read in the Factbook data on over-time ownership patterns 
ownership <- read_xlsx(path="Data/factbook_data_entry_file_ownership FINAL.xlsx")

## code up sinclair ownership, by year 
ownership$sinclair18 <- ifelse(ownership$owner18=="Sinclair Broadcast Group Inc." | 
                                 ownership$owner18=="Sinclair Broadcast Group Inc., California Oregon Broadcasting" | 
                                 ownership$Sinclair_agreement18 == 1,1,0) 
ownership$sinclair17 <- ifelse(ownership$owner17=="Sinclair Broadcast Group Inc." | 
                                 ownership$owner17=="Sinclair Broadcast Group Inc., California Oregon Broadcasting" | 
                                 ownership$Sinclair_agreement17 == 1,1,0) 
ownership$sinclair16 <- ifelse(ownership$owner16=="Sinclair Broadcast Group Inc." | 
                                 ownership$owner16=="Sinclair Broadcast Group Inc., California Oregon Broadcasting" | 
                                 ownership$Sinclair_agreement16 == 1,1,0) 
ownership$sinclair15 <- ifelse(ownership$owner15=="Sinclair Broadcast Group Inc." | 
                                 ownership$owner15=="Sinclair Broadcast Group Inc., California Oregon Broadcasting" | 
                                 ownership$Sinclair_agreement15 == 1,1,0) 
ownership$sinclair14 <- ifelse(ownership$owner14=="Sinclair Broadcast Group Inc." | 
                                 ownership$owner14=="Sinclair Broadcast Group Inc., California Oregon Broadcasting" | 
                                 ownership$Sinclair_agreement14 == 1,1,0) 
ownership$sinclair13 <- ifelse(ownership$owner13=="Sinclair Broadcast Group Inc." | 
                                 ownership$owner13=="Sinclair Broadcast Group Inc., California Oregon Broadcasting" | 
                                 ownership$Sinclair_agreement13 == 1,1,0) 
ownership$sinclair12 <- ifelse(ownership$owner12=="Sinclair Broadcast Group Inc." | 
                                 ownership$owner12=="Sinclair Broadcast Group Inc., California Oregon Broadcasting" | 
                                 ownership$Sinclair_agreement12 == 1,1,0) 
ownership$sinclair11 <- ifelse(ownership$owner11=="Sinclair Broadcast Group Inc." | 
                                 ownership$owner11=="Sinclair Broadcast Group Inc., California Oregon Broadcasting" | 
                                 ownership$Sinclair_agreement11 == 1,1,0) 
ownership$sinclair10 <- ifelse(ownership$owner10=="Sinclair Broadcast Group Inc." | 
                                 ownership$owner10=="Sinclair Broadcast Group Inc., California Oregon Broadcasting" | 
                                 ownership$Sinclair_agreement10 == 1,1,0) 
ownership$sinclair09 <- ifelse(ownership$owner09=="Sinclair Broadcast Group Inc." | 
                                 ownership$owner09=="Sinclair Broadcast Group Inc., California Oregon Broadcasting" | 
                                 ownership$Sinclair_agreement09 == 1,1,0) 
ownership$sinclair08 <- ifelse(ownership$owner08=="Sinclair Broadcast Group Inc." | 
                                 ownership$owner08=="Sinclair Broadcast Group Inc., California Oregon Broadcasting" | 
                                 ownership$Sinclair_agreement08 == 1,1,0) 

## for table: get n stations per year, tabulate and say how many they bought 
numb_by_year <- cbind(sum(ownership$sinclair08,na.rm=T),
                      sum(ownership$sinclair09,na.rm=T),
                      sum(ownership$sinclair10,na.rm=T),
                      sum(ownership$sinclair11,na.rm=T),
                      sum(ownership$sinclair12,na.rm=T),
                      sum(ownership$sinclair13,na.rm=T),
                      sum(ownership$sinclair14,na.rm=T),
                      sum(ownership$sinclair15,na.rm=T),
                      sum(ownership$sinclair16,na.rm=T),
                      sum(ownership$sinclair17,na.rm=T),
                      sum(ownership$sinclair18,na.rm=T))
numb_bought <- cbind(sum(ownership$sinclair08,na.rm=T) - sum(ownership$sinclair08,na.rm=T),
                     sum(ownership$sinclair09,na.rm=T) - sum(ownership$sinclair08,na.rm=T),
                     sum(ownership$sinclair10,na.rm=T) - sum(ownership$sinclair09,na.rm=T),
                     sum(ownership$sinclair11,na.rm=T) - sum(ownership$sinclair10,na.rm=T),
                     sum(ownership$sinclair12,na.rm=T) - sum(ownership$sinclair11,na.rm=T),
                     sum(ownership$sinclair13,na.rm=T) - sum(ownership$sinclair12,na.rm=T),
                     sum(ownership$sinclair14,na.rm=T) - sum(ownership$sinclair13,na.rm=T),
                     sum(ownership$sinclair15,na.rm=T) - sum(ownership$sinclair14,na.rm=T),
                     sum(ownership$sinclair16,na.rm=T) - sum(ownership$sinclair15,na.rm=T),
                     sum(ownership$sinclair17,na.rm=T) - sum(ownership$sinclair16,na.rm=T),
                     sum(ownership$sinclair18,na.rm=T) - sum(ownership$sinclair17,na.rm=T))
colnames(numb_by_year) <- c("2008","2009","2010","2011","2012","2013",
                            "2014","2015","2016","2017","2018")
sinc_summary <- rbind(numb_by_year,numb_bought)
rownames(sinc_summary) <- c("Number Owned","Number Purchased that Year") 

## Number of ZTAs w/ a Sinclair station 
sinclair <- read_dta(file = "Data/sinclair_by_zta.dta") 

pct_with <- sinclair %>% 
  group_by(year) %>% 
  summarise(pct_with = mean(Sinclair, na.rm=T))

## the first two rows are sinc_summary 
## the final row is pct_with 

