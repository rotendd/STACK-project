library(ggplot2)
library(reshape)
source("TEST-DEMOFunctions.R")

PlantLAT <- 39.28682
PlantLON <- -96.1172

Dispersion <- read.delim("JEC-10000m2.txt", header = TRUE, sep = "")
Origin_Dispersion <- ShiftToOrigin("S", Dispersion, PlantLAT, PlantLON)

Functions <- c("ShiftDispersion", "RotateDispersion", "RadialDilation", "AngularStretch")
Scenarios <- c("ShiftedDispersion", "RotatedDispersion", "RadialStretchDispersion", "AngularStretchDispersion")
NumOfRuns <- c(50, 200, 100, 100)

MetricFrames <- c("Metrics_ShiftedDispersion", "Metrics_RotatedDispersion", "Metrics_RadialStretchDispersion", "Metrics_AngularStretchDispersion")
Names_Metrics <- c("MRSMeasure", "MeanAngleMeasure", "STDAngleMeasure", "COMMeasure")

# Create empty data frames to store metric values in
for (a in 1:4) {eval(parse(text = paste(MetricFrames[a], " <- ", "data.frame()", sep = "")))}

# Run all 4 metrics here
for (i in 1:4) {
  
    for (j in 0:NumOfRuns[i]) { # Begin individual iterations here. Matrices 1 & 2 are filled
          
        eval(parse(text = paste(Scenarios[i], " <- ", Functions[i], "(Origin_Dispersion,", j, ")")))
            
        eval(parse(text = paste("Matrix_Model1 <- GridDispersions(Origin_Dispersion, ", Scenarios[i], ", 1)", sep = "")))
        eval(parse(text = paste("Matrix_Model2 <- GridDispersions(Origin_Dispersion, ", Scenarios[i], ", 2)", sep = "")))
    
        # Both matrices are reformatted here
        Melted_Matrix_Model1 <- melt(Matrix_Model1)
        Melted_Matrix_Model2 <- melt(Matrix_Model2)
        names(Melted_Matrix_Model1) <- c("LAT", "LON", "CO2")
        names(Melted_Matrix_Model2) <- c("LAT", "LON", "CO2")
  
        # Each MRS metric value is calculated here
        MRS_Value <- (1/sum(Matrix_Model1))*sum(abs(Matrix_Model1 - Matrix_Model2))
    
        # The Difference in COM is calculated here
        COM_Value <- COMMeasure(Melted_Matrix_Model1, Melted_Matrix_Model2)
    
        # Mean angle difference is calculated here
        Angle1 <- COMAngle(Melted_Matrix_Model1)
        Angle2 <- COMAngle(Melted_Matrix_Model2)
        MeanAngle_Value <- if(abs(Angle1 - Angle2) <= 180) {abs(Angle1 - Angle2)} else {360 - abs(Angle1 - Angle2)}
        
        # Calculating the standard deviation of dispersion
        Rotated_Dispersion1 <- RotateToAxis(Melted_Matrix_Model1, Angle1)
        Rotated_Dispersion2 <- RotateToAxis(Melted_Matrix_Model2, Angle2)
        STDAngles1 <- sd((180/pi)*atan2(Rotated_Dispersion1$LAT, Rotated_Dispersion1$LON))
        STDAngles2 <- sd((180/pi)*atan2(Rotated_Dispersion2$LAT, Rotated_Dispersion2$LON))
        STDAngle_Value <- abs(STDAngles1-STDAngles2)
    
        eval(parse(text = paste(MetricFrames[i], "[j+1,1] <- MRS_Value", sep = "")))
        eval(parse(text = paste(MetricFrames[i], "[j+1,2] <- COM_Value", sep = "")))
        eval(parse(text = paste(MetricFrames[i], "[j+1,3] <- MeanAngle_Value", sep = "")))
        eval(parse(text = paste(MetricFrames[i], "[j+1,4] <- STDAngle_Value", sep = "")))
        
    } # End individual iterations here. Matrices 1 & 2 have been filled
    
}

for (i in 1:4) {eval(parse(text = paste("names(", MetricFrames[i], ")", " <- ", "c('MRSValue', 'COMValue', 'MeanAngleValue', 'STDAngleValue')", sep = "")))}
