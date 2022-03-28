# ---
title: "slope analysis"
author: "Cedric and Maria and Mathilde"
date: "03/03/2020"
output: 
  html_document:
    number_sections: true
---






```r
slope <- sqldf("SELECT slope, country from dbeel_rivers.rn_rna")
# this slope is indicated as per mille by Pella et al (2012)
ggplot(slope)+ geom_density(aes(x=slope, fill=country), alpha=0.5)+ scale_x_continuous(limits=c(0,1))
```

```
## Warning: Removed 52451 rows containing non-finite values (stat_density).
```

![plot of chunk test](figure/test-1.png)

```r
tapply(slope$slope,slope$country,summary)
```

```
## $FR
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
## 0.00000 0.00230 0.00700 0.01879 0.01710 0.91240      87 
## 
## $PT
##    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
##    0.00    0.03    0.07    0.09    0.12    0.41   49333 
## 
## $SP
##     Min.  1st Qu.   Median     Mean  3rd Qu.     Max.     NA's 
##  0.00000  0.05575  0.11393  0.17702  0.22226 10.00000        1
```

```r
summary(slope_france)
```

```
##      slope        
##  Min.   :0.00000  
##  1st Qu.:0.00230  
##  Median :0.00700  
##  Mean   :0.01879  
##  3rd Qu.:0.01710  
##  Max.   :0.91240  
##  NA's   :87
```
