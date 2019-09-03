setwd("C:/Users/vnavarro/OneDrive - University of Iowa/UIOWA/2019/VisionLab/PSY4020/demo_exp")
require(rprime)

for (f in dir(pattern = '*.edat2')){
 h =  read_eprime(f)
}