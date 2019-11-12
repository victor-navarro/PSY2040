#import ggplot2 package for plotting, install if it is not installed
ggplotinstall = require(ggplot2)
if (!ggplotinstall){
  install.packages('ggplot2')
  library(ggplot2)
}
#read data
theData = read.table("C:/Users/vnavarro/OneDrive - University of Iowa/UIOWA/2019/VisionLab/PSY4020/dataR/data.txt",
                     sep = '\t', header = T)

#trim reaction times and incorrect trials
theData = theData[theData$REACTION_TIME > 100 & theData$REACTION_TIME < 1500 & theData$ACCURACY, ]
#get summary table
t = aggregate(REACTION_TIME~Subject+ISI+Target_Type+Set_Size, theData, mean)
#generate plot
ggplot(t, aes(x = Set_Size, y = REACTION_TIME, colour = Target_Type)) + 
  stat_summary(geom = 'line', fun.y = 'mean') + 
  stat_summary(geom = 'pointrange', fun.data = 'mean_se') +
  theme_bw() +
  facet_wrap(~ISI)

#fit regression model for each ISI (slope estimates and differences)
m0 = lm(REACTION_TIME~Set_Size*Target_Type, data = t[t$ISI == 0, ])
summary(m0)
m200 = lm(REACTION_TIME~Set_Size*Target_Type, data = t[t$ISI == 200, ])
summary(m200)