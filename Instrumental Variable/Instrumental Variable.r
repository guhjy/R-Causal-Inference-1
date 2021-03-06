rm(list=ls())
library(foreign)
library(sandwich)
library(lmtest)
library(sem)  
library(AER)
library(gmodels)
library(stargazer)
library(Hmisc)

rainfall<-read.dta(file.choose())
## mss_repdata_recode
attach(rainfall)

robust.se <- function(model, cluster){
  require(sandwich)
  require(lmtest)
  M <- length(unique(cluster))
  N <- length(cluster)
  K <- model$rank
  dfc <- (M/(M - 1)) * ((N - 1)/(N - K))
  uj <- apply(estfun(model), 2, function(x) tapply(x, cluster, sum))
  rcse.cov <- dfc * sandwich(model, meat = crossprod(uj)/N)
  rcse.se <- coeftest(model, rcse.cov)
  return(list(rcse.cov, rcse.se))
}


#x_fl: y_0 polity2l ethfrac relfrac Oil lpopl1 lmtnest
#x_year: Iccyear*


x_fl <- "y_0+polity2l+ethfrac+relfrac+Oil+lmtnest+lpopl1+"

x_year <- "Iccyear1+Iccyear2+Iccyear3+Iccyear4+Iccyear5+Iccyear6+Iccyear7+Iccyear8+Iccyear9+Iccyear10+Iccyear11+Iccyear12+Iccyear13+Iccyear14+Iccyear15+Iccyear16+Iccyear17+Iccyear18+Iccyear19+Iccyear20+Iccyear21+Iccyear22+Iccyear23+Iccyear24+Iccyear25+Iccyear26+Iccyear27+Iccyear28+Iccyear29+Iccyear30+Iccyear31+Iccyear32+Iccyear33+Iccyear34+Iccyear35+Iccyear36+Iccyear37+Iccyear38+Iccyear39+Iccyear40"
x_country <- "Iccode1+Iccode2+Iccode3+Iccode4+Iccode5+Iccode6+Iccode7+Iccode8+Iccode9+Iccode10+Iccode11+Iccode12+Iccode13+Iccode14+Iccode15+Iccode16+Iccode17+Iccode18+Iccode19+Iccode20+Iccode21+Iccode22+Iccode23+Iccode24+Iccode25+Iccode26+Iccode27+Iccode28+Iccode29+Iccode30+Iccode31+Iccode32+Iccode33+Iccode34+Iccode35+Iccode36+Iccode37+Iccode38+Iccode39+Iccode40+"

#table 2
mss2.1 <- lm(gdp_g~GPCP_g+GPCP_g_l,rainfall)
summary(mss2.1)
lm2.1 <- robust.se(mss2.1,ccode)

mss2.2 <- lm(paste0("gdp_g~GPCP_g+GPCP_g_l+", x_fl, x_year),rainfall)
summary(mss2.2)
lm2.2 <- robust.se(mss2.2,rainfall$ccode)

mss2.3 <- lm(paste0("gdp_g~GPCP_g+GPCP_g_l+", x_country, x_year),rainfall)
summary(mss2.3)
lm2.3 <- robust.se(mss2.3,ccode)

mss2.4 <- lm(paste0("gdp_g~GPCP_g+GPCP_g_l+GPCP_g_fl+", x_country, x_year),rainfall)
summary(mss2.4)
lm2.4 <- robust.se(mss2.4,ccode)

rainfall1 <- subset(rainfall, select=c("ccode","gdp_g","GPCP_g","GPCP_g_l","tot_100_g",strsplit(x_year, "[+]")[[1]], strsplit(x_country, "[+]")[[1]]))
rainfall1 <- na.omit(rainfall1)

mss2.5 <- lm(paste0("gdp_g~GPCP_g+GPCP_g_l+tot_100_g+", x_country, x_year),rainfall1)
summary(mss2.5)
lm2.5 <- robust.se(mss2.5,rainfall1$ccode)

stargazer(lm2.1[[2]], lm2.2[[2]], lm2.3[[2]], lm2.4[[2]], lm2.5[[2]], dep.var.caption ="Ordinary Least Squares",
          keep=c("GPCP_g","GPCP_g_l","GPCP_g_fl","tot_100_g","y_0","polity2l","polity2l_6",
          "ethfrac", "relfrac","Oil","lmtnest","lpopl1"), covariate.labels=c("Growth in rainfall, t",
          "Growth in rainfall,t-1","Log(GDP per capita),1979","Democracy(Polity IV), t-1",
          "Ethnolinguistic fractionaliztion","Religious fractionalization","Oil-exporting country",
          "Log(mountainous)","Log(national population),t-1","Growth in rainfall, t+1", "Growth in terms of trade, t"),
          no.space = TRUE)


stargazer(mss2.1, mss2.2, mss2.3, mss2.4, mss2.5, dep.var.caption ="Ordinary Least Squares",
          keep=c("GPCP_g","GPCP_g_l","GPCP_g_fl","tot_100_g","y_0","polity2l","polity2l_6",
                 "ethfrac", "relfrac","Oil","lmtnest","lpopl1"), covariate.labels=c("Growth in rainfall, t",
                                                                                    "Growth in rainfall,t-1","Log(GDP per capita),1979","Democracy(Polity IV), t-1",
                                                                                    "Ethnolinguistic fractionaliztion","Religious fractionalization","Oil-exporting country",
                                                                                    "Log(mountainous)","Log(national population),t-1","Growth in rainfall, t+1", "Growth in terms of trade, t"),
          no.space = TRUE)
## The purpose to run stargazer here is to achieve r^2, # of obs


#table 3
mss3.1 <- lm(paste0("any_prio~GPCP_g+GPCP_g_l+", x_country, x_year),rainfall)
summary(mss3.1)
lm3.1 <- robust.se(mss3.1,ccode)

mss3.2 <- lm(paste0("war_prio~GPCP_g+GPCP_g_l+", x_country, x_year),rainfall)
summary(mss3.2)
lm3.2 <- robust.se(mss3.2,ccode)

stargazer(lm3.1[[2]], lm3.2[[2]], dep.var.caption ="Dependent Variable",
          keep=c("GPCP_g","GPCP_g_l"),  column.labels = c("Civil Conflict 25 Deaths(OLS)",
          "Civil Conflict 1000 Deaths(OLS)"),covariate.labels=c("Growth in rainfall, t",
          "Growth in rainfall,t-1"), no.space = TRUE)

stargazer(mss3.1, mss3.2, dep.var.caption ="Dependent Variable",
          keep=c("GPCP_g","GPCP_g_l"), covariate.labels=c("Growth in rainfall, t",
                                                          "Growth in rainfall,t-1"),no.space = TRUE)


#table 4
mfxboot <- function(modform,dist,data,boot=1000,digits=3){
  x <- glm(modform, family=binomial(link=dist),data)
  # get marginal effects
  pdf <- ifelse(dist=="probit",
                mean(dnorm(predict(x, type = "link"))),
                mean(dlogis(predict(x, type = "link"))))
  marginal.effects <- pdf*coef(x)
  # start bootstrap
  bootvals <- matrix(rep(NA,boot*length(coef(x))), nrow=boot)
  set.seed(1111)
  for(i in 1:boot){
    samp1 <- data[sample(1:dim(data)[1],replace=T,dim(data)[1]),]
    x1 <- glm(modform, family=binomial(link=dist),samp1)
    pdf1 <- ifelse(dist=="probit",
                   mean(dnorm(predict(x, type = "link"))),
                   mean(dlogis(predict(x, type = "link"))))
    bootvals[i,] <- pdf1*coef(x1)
  }
  res <- cbind(marginal.effects,apply(bootvals,2,sd),marginal.effects/apply(bootvals,2,sd))
  if(names(x$coefficients[1])=="(Intercept)"){
    res1 <- res[2:nrow(res),]
    res2 <- matrix(as.numeric(sprintf(paste("%.",paste(digits,"f",sep=""),sep=""),res1)),nrow=dim(res1)[1])    
    rownames(res2) <- rownames(res1)
  } else {
    res2 <- matrix(as.numeric(sprintf(paste("%.",paste(digits,"f",sep=""),sep="")),nrow=dim(res)[1]))
    rownames(res2) <- rownames(res)
  }
  colnames(res2) <- c("marginal.effect","standard.error","z.ratio") 
  return(res2)
}
four.base <- c("gdp_g","gdp_g_l")
probit <- glm(as.formula(paste("any_prio~",paste(four.base,collapse="+"),"+",paste(x_fl,collapse="+"),"+year")),family=binomial(link="probit"),data)


mss4.1 <- glm(paste0("any_prio~gdp_g+gdp_g_l+", x_fl, "year"), family=binomial(link="probit"), rainfall)
summary(mss4.1)
glm4.1 <- robust.se(mss4.1,rainfall$ccode)


mss4.2 <- lm(paste0("any_prio~gdp_g+gdp_g_l+", x_fl, "year"), data = rainfall)
summary(mss4.2)
lm4.2 <- robust.se(mss4.2,rainfall$ccode)


x_year1 <- "Iccyear1+Iccyear2+Iccyear3+Iccyear4+Iccyear5+Iccyear6+Iccyear7+Iccyear8+Iccyear9+Iccyear10+Iccyear11+Iccyear12+Iccyear13+Iccyear14+Iccyear15+Iccyear16+Iccyear17+Iccyear18+Iccyear19+Iccyear20+Iccyear21+Iccyear22+Iccyear23+Iccyear24+Iccyear25+Iccyear26+Iccyear27+Iccyear28+Iccyear29+Iccyear30+Iccyear31+Iccyear32+Iccyear33+Iccyear34+Iccyear35+Iccyear36+Iccyear37+Iccyear38+Iccyear39+Iccyear40+Iccyear41"
x_country1 <- "Iccode1+Iccode2+Iccode3+Iccode4+Iccode5+Iccode6+Iccode7+Iccode8+Iccode9+Iccode10+Iccode11+Iccode12+Iccode13+Iccode14+Iccode15+Iccode16+Iccode17+Iccode18+Iccode19+Iccode20+Iccode21+Iccode22+Iccode23+Iccode24+Iccode25+Iccode26+Iccode27+Iccode28+Iccode29+Iccode30+Iccode31+Iccode32+Iccode33+Iccode34+Iccode35+Iccode36+Iccode37+Iccode38+Iccode39+Iccode40+Iccode41+"


mss4.3 <- lm(paste0("any_prio~gdp_g+gdp_g_l+", x_fl, x_year1), data = rainfall)
summary(mss4.3)
lm4.3 <- robust.se(mss4.3,rainfall$ccode)

mss4.4 <- lm(paste0("any_prio~gdp_g+gdp_g_l+", x_country1, x_year1), data = rainfall)
summary(mss4.4)
lm4.4 <-robust.se(mss4.4,ccode)

mss4.5 <- ivreg(any_prio~gdp_g+gdp_g_l
                +y_0+polity2l+ethfrac+relfrac+Oil+lmtnest+lpopl1
                +Iccyear1+Iccyear2+Iccyear3+Iccyear4+Iccyear5+Iccyear6+Iccyear7+Iccyear8+Iccyear9+Iccyear10
                +Iccyear11+Iccyear12+Iccyear13+Iccyear14+Iccyear15+Iccyear16+Iccyear17+Iccyear18+Iccyear19+Iccyear20
                +Iccyear21+Iccyear22+Iccyear23+Iccyear24+Iccyear25+Iccyear26+Iccyear27+Iccyear28+Iccyear29+Iccyear30
                +Iccyear31+Iccyear32+Iccyear33+Iccyear34+Iccyear35+Iccyear36+Iccyear37+Iccyear38+Iccyear39+Iccyear40+Iccyear41
                |GPCP_g+GPCP_g_l
                +y_0+polity2l+ethfrac+relfrac+Oil+lmtnest+lpopl1
                +Iccyear1+Iccyear2+Iccyear3+Iccyear4+Iccyear5+Iccyear6+Iccyear7+Iccyear8+Iccyear9+Iccyear10
                +Iccyear11+Iccyear12+Iccyear13+Iccyear14+Iccyear15+Iccyear16+Iccyear17+Iccyear18+Iccyear19+Iccyear20
                +Iccyear21+Iccyear22+Iccyear23+Iccyear24+Iccyear25+Iccyear26+Iccyear27+Iccyear28+Iccyear29+Iccyear30
                +Iccyear31+Iccyear32+Iccyear33+Iccyear34+Iccyear35+Iccyear36+Iccyear37+Iccyear38+Iccyear39+Iccyear40+Iccyear41,
                data=rainfall)

summary(mss4.5)
lm4.5 <- robust.se(mss4.5,ccode)

mss4.6 <- ivreg(any_prio~gdp_g+gdp_g_l
                +Iccyear1+Iccyear2+Iccyear3+Iccyear4+Iccyear5+Iccyear6+Iccyear7+Iccyear8+Iccyear9+Iccyear10
                +Iccyear11+Iccyear12+Iccyear13+Iccyear14+Iccyear15+Iccyear16+Iccyear17+Iccyear18+Iccyear19+Iccyear20
                +Iccyear21+Iccyear22+Iccyear23+Iccyear24+Iccyear25+Iccyear26+Iccyear27+Iccyear28+Iccyear29+Iccyear30
                +Iccyear31+Iccyear32+Iccyear33+Iccyear34+Iccyear35+Iccyear36+Iccyear37+Iccyear38+Iccyear39+Iccyear40
                +Iccode1+Iccode2+Iccode3+Iccode4+Iccode5+Iccode6+Iccode7+Iccode8+Iccode9+Iccode10
                +Iccode11+Iccode12+Iccode13+Iccode14+Iccode15+Iccode16+Iccode17+Iccode18+Iccode19+Iccode20
                +Iccode21+Iccode22+Iccode23+Iccode24+Iccode25+Iccode26+Iccode27+Iccode28+Iccode29+Iccode30
                +Iccode31+Iccode32+Iccode33+Iccode34+Iccode35+Iccode36+Iccode37+Iccode38+Iccode39+Iccode40
                |GPCP_g+GPCP_g_l
                +Iccyear1+Iccyear2+Iccyear3+Iccyear4+Iccyear5+Iccyear6+Iccyear7+Iccyear8+Iccyear9+Iccyear10
                +Iccyear11+Iccyear12+Iccyear13+Iccyear14+Iccyear15+Iccyear16+Iccyear17+Iccyear18+Iccyear19+Iccyear20
                +Iccyear21+Iccyear22+Iccyear23+Iccyear24+Iccyear25+Iccyear26+Iccyear27+Iccyear28+Iccyear29+Iccyear30
                +Iccyear31+Iccyear32+Iccyear33+Iccyear34+Iccyear35+Iccyear36+Iccyear37+Iccyear38+Iccyear39+Iccyear40
                +Iccode1+Iccode2+Iccode3+Iccode4+Iccode5+Iccode6+Iccode7+Iccode8+Iccode9+Iccode10
                +Iccode11+Iccode12+Iccode13+Iccode14+Iccode15+Iccode16+Iccode17+Iccode18+Iccode19+Iccode20
                +Iccode21+Iccode22+Iccode23+Iccode24+Iccode25+Iccode26+Iccode27+Iccode28+Iccode29+Iccode30
                +Iccode31+Iccode32+Iccode33+Iccode34+Iccode35+Iccode36+Iccode37+Iccode38+Iccode39+Iccode40,
                data=rainfall)


summary(mss4.6)
lm4.6 <- robust.se(mss4.6, ccode)


mss4.7 <- ivreg(war_prio~gdp_g+gdp_g_l
                +Iccyear1+Iccyear2+Iccyear3+Iccyear4+Iccyear5+Iccyear6+Iccyear7+Iccyear8+Iccyear9+Iccyear10
                +Iccyear11+Iccyear12+Iccyear13+Iccyear14+Iccyear15+Iccyear16+Iccyear17+Iccyear18+Iccyear19+Iccyear20
                +Iccyear21+Iccyear22+Iccyear23+Iccyear24+Iccyear25+Iccyear26+Iccyear27+Iccyear28+Iccyear29+Iccyear30
                +Iccyear31+Iccyear32+Iccyear33+Iccyear34+Iccyear35+Iccyear36+Iccyear37+Iccyear38+Iccyear39+Iccyear40
                +Iccode1+Iccode2+Iccode3+Iccode4+Iccode5+Iccode6+Iccode7+Iccode8+Iccode9+Iccode10
                +Iccode11+Iccode12+Iccode13+Iccode14+Iccode15+Iccode16+Iccode17+Iccode18+Iccode19+Iccode20
                +Iccode21+Iccode22+Iccode23+Iccode24+Iccode25+Iccode26+Iccode27+Iccode28+Iccode29+Iccode30
                +Iccode31+Iccode32+Iccode33+Iccode34+Iccode35+Iccode36+Iccode37+Iccode38+Iccode39+Iccode40
                |GPCP_g+GPCP_g_l
                +Iccyear1+Iccyear2+Iccyear3+Iccyear4+Iccyear5+Iccyear6+Iccyear7+Iccyear8+Iccyear9+Iccyear10
                +Iccyear11+Iccyear12+Iccyear13+Iccyear14+Iccyear15+Iccyear16+Iccyear17+Iccyear18+Iccyear19+Iccyear20
                +Iccyear21+Iccyear22+Iccyear23+Iccyear24+Iccyear25+Iccyear26+Iccyear27+Iccyear28+Iccyear29+Iccyear30
                +Iccyear31+Iccyear32+Iccyear33+Iccyear34+Iccyear35+Iccyear36+Iccyear37+Iccyear38+Iccyear39+Iccyear40
                +Iccode1+Iccode2+Iccode3+Iccode4+Iccode5+Iccode6+Iccode7+Iccode8+Iccode9+Iccode10
                +Iccode11+Iccode12+Iccode13+Iccode14+Iccode15+Iccode16+Iccode17+Iccode18+Iccode19+Iccode20
                +Iccode21+Iccode22+Iccode23+Iccode24+Iccode25+Iccode26+Iccode27+Iccode28+Iccode29+Iccode30
                +Iccode31+Iccode32+Iccode33+Iccode34+Iccode35+Iccode36+Iccode37+Iccode38+Iccode39+Iccode40,
                data=rainfall)
summary(mss4.7)
lm4.7 <- robust.se(mss4.7, rainfall$ccode)


stargazer(glm4.1[[2]], lm4.2[[2]],lm4.3[[2]],lm4.4[[2]],lm4.5[[2]],lm4.6[[2]],lm4.7[[2]], 
          column.separate = c(6,1),column.labels=c("Probit","OLS","OLS","OLS","IV-2SLS",
          "IV-2SLS","IV-2SLS"), dep.var.caption="",
          dep.var.labels=c("Economic growth rate, t","Economic growth rate, t-1","Log(GDP per capita),1979","Democracy(Polity IV), t-1",
                           "Ethnolinguistic fractionaliztion","Religious fractionalization","Oil-exporting country",
                           "Log(mountainous)","Log(national population),t-1" ),
          keep = c("gdp_g","gdp_g_l","y_0","polity2l",
                                       "ethfrac", "relfrac","Oil","lmtnest","lpopl1"), no.space= TRUE)


# table 6 #
###########

## R code below to replicate table 6 does not run well, I replicated the table in STATA

attach(rainfall)

rainfall$year_actual <- rainfall$year
rainfall$year <- rainfall$year_actual - 1978
rainfall$Iccode = factor(rainfall$ccode)
rainfall$dummies = model.matrix(~rainfall$Iccode)
rainfall$Iccyear = rainfall$dummies*rainfall$year

finalvars.any <- c("any_prio_on",four.base,"Iccode","Iccyear","GPCP_g","GPCP_g_l","ccode")
finalvars.war <- c("war_prio_on",four.base,"Iccode","Iccyear","GPCP_g","GPCP_g_l","ccode")
cleandata.any <- rainfall[finalvars.any]
cleandata.any <- cleandata.any[complete.cases(cleandata.any),]
cleandata.any <- cleandata.any[1:555,]
cleandata.war <- rainfall[finalvars.war]
cleandata.war <- cleandata.war[complete.cases(cleandata.war),]
onset.1 <- ivreg(as.formula(paste("any_prio_on~",paste(four.base,collapse="+"),"+Iccyear+factor(Iccode) | GPCP_g+GPCP_g_l+Iccyear+factor(Iccode)")),
                 data=cleandata.any) ## I can't get this to work and I don't know why. Given more pressing matters, I'll do just this one part in STATA.
rob.onset.1 <- robust.se(onset.1,cleandata.any$ccode)
six.results <- NULL
six.results <- lm4.7[[2]][2:3,1:2]
onset.2 <- ivreg(as.formula(paste("war_prio_on~",paste(four.base,collapse="+"),"+Iccyear+factor(Iccode) | GPCP_g+GPCP_g_l+Iccyear+factor(Iccode)")),
                 data=cleandata.war)
rob.onset.2 <- robust.se(onset.2,cleandata.war$ccode)
six.results <- rbind(six.results,rob.onset.2[[2]][2:3,1:2])
stargazer(onset.2,onset.2,keep=c("gdp_g","gdp_g_l"),covariate.labels=c("Economic Growth rate, t","Economic growth rate, t-1"))



# Placebo test
# take advantage of the country-specific heteorgeneity to construct a placebo test
# to provide circumstantial evidence on the exclusion restriction 

test.i<-NULL
sum.test.i<-NULL
sub.test<-NULL
for (i in unique(rainfall$ccode)) {
  test.i <- lm(gdp_g~GPCP_g+GPCP_g_l,data=subset(rainfall,ccode == i))
  sum.test.i <- summary(test.i)
  sub.test <- rbind(sub.test,c(i,round(coef(sum.test.i)[2],3),round(coef(sum.test.i)[3],3)))
}

country.reg <- as.data.frame(as.matrix(sub.test))
colnames(country.reg) <-  c("Country", "Rainfall", "Rainfall-1")
country.reg <- country.reg[order(country.reg$Rainfall, country.reg$Rainfall-1) , ]

#the countries of which coefficients are either negative or zero(contrary to the one hypothesis) are:
#471, 580, 481, 522, 520, 501, 435

rainfall.restrict <- subset(rainfall, ccode == 471 | ccode == 580 |
                           ccode == 481 | ccode == 522 |
                           ccode == 520 | ccode == 501 |
                           ccode == 435 )

detach(rainfall)
attach(rainfall.restrict)

#re-run the first-stage regression just using the countries identified above
mss.p1 <- lm(gdp_g~GPCP_g+GPCP_g_l, rainfall.restrict)
p1 <- robust.se(mss.p1,ccode)

mss.p2 <- lm(paste0("gdp_g~GPCP_g+GPCP_g_l+", x_fl, x_year1), rainfall.restrict)
p2 <- robust.se(mss.p2,ccode)

mss.p3 <- lm(paste0("gdp_g~GPCP_g+GPCP_g_l+", x_country1, x_year1), rainfall.restrict)
p3 <- robust.se(mss.p3,ccode)

mss.p4 <- lm(paste0("gdp_g~GPCP_g+GPCP_g_l+GPCP_g_fl+", x_country1, x_year1), rainfall.restrict)
p4 <- robust.se(mss.p4,ccode)

mss.p5 <- lm(paste0("gdp_g~GPCP_g+GPCP_g_l+tot_100_g+", x_country1, x_year1), rainfall.restrict)
data2.clean.p <- na.omit(subset(data2.restrict, select=c("ccode","gdp_g","GPCP_g","GPCP_g_l","tot_100_g",strsplit(x_year1, "[+]")[[1]], strsplit(x_country1, "[+]")[[1]])))
p5 <- robust.se(mss.p5,data2.clean.p$ccode)

stargazer(p1[[2]],p2[[2]],p3[[2]],p4[[2]],p5[[2]])

##re-run the reduced form regression just using the countries identified above
mss.p6 <- lm(paste0("any_prio~GPCP_g+GPCP_g_l+", x_country1, x_year1), rainfall.restrict)
p6 <- robust.se(mss.p6,ccode)

mss.p7 <- lm(paste0("war_prio~GPCP_g+GPCP_g_l+", x_country1, x_year1), rainfall.restrict)
p7 <- robust.se(mss.p7,ccode)

stargazer(p6[[2]],p7[[2]])
