library(ggplot2)

Dispersion <- read.delim("JEC-10000m2.txt", header = TRUE, sep = "")[,1:7]

Dispersion$LAT <- Dispersion$LAT - 39.2865
Dispersion$LON <- Dispersion$LON + 96.1172

Resolution <- 0.1

Metric = data.frame()

for (i in 0:10) {
  
  theta <- i/5
  
  Rot_Dispersion <- cbind(Dispersion[,1:4],
                          Dispersion$LON*sinpi(theta) + Dispersion$LAT*cospi(theta),
                          Dispersion$LON*cospi(theta) - Dispersion$LAT*sinpi(theta),
                          Dispersion[,7])
  
  names(Rot_Dispersion) <- c("YEAR", "MO", "DA", "HR", "LAT", "LON", "CO2")
  
  # Metric
  
  DayModel1 <- Rot_Dispersion
  DayModel2 <- Dispersion
  
  x_range <- max( max(DayModel1$LON), max(DayModel2$LON)) - min(min(DayModel1$LON), min(DayModel2$LON)) + 1
  y_range <- max( max(DayModel1$LAT), max(DayModel2$LAT)) - min(min(DayModel1$LAT), min(DayModel2$LAT)) + 1
  
  x_steps <- round(x_range/Resolution, 0)
  y_steps <- round(y_range/Resolution, 0)
  
  DayModel1_Matrix <- matrix(0, nrow = y_steps, ncol = x_steps)
  DayModel2_Matrix <- matrix(0, nrow = y_steps, ncol = x_steps)
  
  # This section of code executes the MRS measure
  
  minLON <- min(min(DayModel1$LON), min(DayModel2$LON))
  minLAT <- min(min(DayModel1$LAT), min(DayModel2$LAT))
  
  for (g in 1:y_steps) {
    
    for(h in 1:x_steps) {
      
      CellAveragedPollutant_1 <- mean(DayModel1[,7][DayModel1$LON >= minLON + Resolution*(h-1) & DayModel1$LON < minLON + Resolution*h &
                                                    DayModel1$LAT >= minLAT + Resolution*(g-1) & DayModel1$LAT < minLAT + Resolution*g])
      
      CellAveragedPollutant_2 <- mean(DayModel2[,7][DayModel2$LON >= minLON + Resolution*(h-1) & DayModel2$LON < minLON + Resolution*h &
                                                    DayModel2$LAT >= minLAT + Resolution*(g-1) & DayModel2$LAT < minLAT + Resolution*g])
      
      DayModel1_Matrix[g,h] <- ifelse(is.nan(CellAveragedPollutant_1), 0, CellAveragedPollutant_1)
      DayModel2_Matrix[g,h] <- ifelse(is.nan(CellAveragedPollutant_2), 0, CellAveragedPollutant_2)
      
    }
    
  }
  
  library(reshape2)
  
  longData<-melt(DayModel1_Matrix)
  longData<-longData[longData$value!=0,]
  
  longData2<-melt(DayModel2_Matrix)
  longData2<-longData2[longData2$value!=0,]
  
  longData3<-melt(sign(DayModel2_Matrix - DayModel1_Matrix)*log(abs(DayModel2_Matrix - DayModel1_Matrix)))
  longData3<-longData3[longData3$value!=0,]
  
  ggplot(longData, aes(x = Var2, y = Var1)) + 
    geom_raster(aes(fill=value)) + 
    scale_fill_gradient(low="grey90", high="red") +
    labs(x="letters", y="LETTERS", title="Matrix") +
    theme_bw() + theme(axis.text.x=element_text(size=9, angle=0, vjust=0.3),
                            axis.text.y=element_text(size=9),
                            plot.title=element_text(size=11))
  

  
  ggplot(longData2, aes(x = Var2, y = Var1)) + 
    geom_raster(aes(fill=value)) + 
    scale_fill_gradient(low="grey90", high="red") +
    labs(x="letters", y="LETTERS", title="Matrix") +
    theme_bw() + theme(axis.text.x=element_text(size=9, angle=0, vjust=0.3),
                       axis.text.y=element_text(size=9),
                       plot.title=element_text(size=11))
  
  
  
  SaveFile <- ggplot(longData3, aes(x = Var2, y = Var1)) + 
            geom_raster(aes(fill=value)) + 
            scale_fill_gradient(low="grey90", high="red") +
            labs(x="letters", y="LETTERS", title="Matrix") +
            theme_bw() + theme(axis.text.x=element_text(size=9, angle=0, vjust=0.3),
                                axis.text.y=element_text(size=9),
                                plot.title=element_text(size=11))
  
  FileName <- paste("Angle",i, ".png", sep = "")
  ggsave(plot = SaveFile, FileName, device = "png")
  
  # Metric calculation is performed here (as a percentage %)
  Metric[i+1,1] <- theta
  Metric[i+1,2] <- ((100*20000*(Resolution*111000)^2)/(2*(12591532084.8523/366)))*sum(abs(DayModel2_Matrix - DayModel1_Matrix))
  
  
}




# Dilation Metric

Metric2 <- data.frame()

for (i in 0:10) {
  
  dilation <- 1+(i/10)
  
  Dil_Dispersion <- cbind(Dispersion[,1:4], Dispersion$LAT*dilation, Dispersion$LON*dilation, Dispersion[,7])
  
  names(Dil_Dispersion) <- c("YEAR", "MO", "DA", "HR", "LAT", "LON", "CO2")
  
  # Metric
  
  DayModel1 <- Dil_Dispersion
  DayModel2 <- Dispersion
  
  x_range <- max(max(DayModel1$LON), max(DayModel2$LON)) - min(min(DayModel1$LON), min(DayModel2$LON)) + 1
  y_range <- max(max(DayModel1$LAT), max(DayModel2$LAT)) - min(min(DayModel1$LAT), min(DayModel2$LAT)) + 1
  
  x_steps <- round(x_range/Resolution, 0)
  y_steps <- round(y_range/Resolution, 0)
  
  DayModel1_Matrix <- matrix(0, nrow = y_steps, ncol = x_steps)
  DayModel2_Matrix <- matrix(0, nrow = y_steps, ncol = x_steps)
  
  # Metric below
  
  minLON <- min(min(DayModel1$LON), min(DayModel2$LON))
  minLAT <- min(min(DayModel1$LAT), min(DayModel2$LAT))
  
  for (g in 1:y_steps) {
    
    for(h in 1:x_steps) {
      
      CellAveragedPollutant_1 <- mean(DayModel1[,7][DayModel1$LON >= minLON + Resolution*(h-1) & DayModel1$LON < minLON + Resolution*h &
                                                    DayModel1$LAT >= minLAT + Resolution*(g-1) & DayModel1$LAT < minLAT + Resolution*g])
      
      CellAveragedPollutant_2 <- mean(DayModel2[,7][DayModel2$LON >= minLON + Resolution*(h-1) & DayModel2$LON < minLON + Resolution*h &
                                                    DayModel2$LAT >= minLAT + Resolution*(g-1) & DayModel2$LAT < minLAT + Resolution*g])
      
      DayModel1_Matrix[g,h] <- ifelse(is.nan(CellAveragedPollutant_1), 0, CellAveragedPollutant_1)
      DayModel2_Matrix[g,h] <- ifelse(is.nan(CellAveragedPollutant_2), 0, CellAveragedPollutant_2)
      
    }
    
  }
  
  # Metric calculation is performed here (as a percentage %)
  Metric2[i+1,1] <- dilation
  Metric2[i+1,2] <- ((100*20000*(Resolution*111000)^2)/(2*(12591532084.8523/366)))*sum(abs(DayModel2_Matrix - DayModel1_Matrix))

  
  
  
  
  longData<-melt(DayModel1_Matrix)
  longData<-longData[longData$value!=0,]
  
  longData2<-melt(DayModel2_Matrix)
  longData2<-longData2[longData2$value!=0,]
  
  longData3<-melt(sign(DayModel2_Matrix - DayModel1_Matrix)*log(DayModel2_Matrix - DayModel1_Matrix))
  longData3<-longData3[longData3$value!=0,]
  
  ggplot(longData, aes(x = Var2, y = Var1)) + 
    geom_raster(aes(fill=value)) + 
    scale_fill_gradient(low="grey90", high="red") +
    labs(x="letters", y="LETTERS", title="Matrix") +
    theme_bw() + theme(axis.text.x=element_text(size=9, angle=0, vjust=0.3),
                       axis.text.y=element_text(size=9),
                       plot.title=element_text(size=11))
  
  
  
  ggplot(longData2, aes(x = Var2, y = Var1)) + 
    geom_raster(aes(fill=value)) + 
    scale_fill_gradient(low="grey90", high="red") +
    labs(x="letters", y="LETTERS", title="Matrix") +
    theme_bw() + theme(axis.text.x=element_text(size=9, angle=0, vjust=0.3),
                       axis.text.y=element_text(size=9),
                       plot.title=element_text(size=11))
  
  
  
  SaveFile <- ggplot(longData3, aes(x = Var2, y = Var1)) + 
    geom_raster(aes(fill=value)) + 
    scale_fill_gradient(low="grey90", high="red") +
    labs(x="letters", y="LETTERS", title="Matrix") +
    theme_bw() + theme(axis.text.x=element_text(size=9, angle=0, vjust=0.3),
                       axis.text.y=element_text(size=9),
                       plot.title=element_text(size=11))
  
  FileName <- paste("Stretch", i, ".png", sep = "")
  ggsave(plot = SaveFile, FileName, device = "png")
    
}

Plot1 <- ggplot(data = Metric, aes(x = V1, y = V2)) +
            geom_line() +
            xlab("Angle (x pi)") +
            ylab("Metric Value (%)") +
            ggtitle("Angular Sensitivity") +
            theme_bw()

Plot2 <- ggplot(data = Metric2, aes(x = V1, y = V2)) +
            geom_line() +
            xlab("Dilation Factor") +
            ylab("Metric Value (%)") +
            ggtitle("Radial Sensitivity") +
            theme_bw()



