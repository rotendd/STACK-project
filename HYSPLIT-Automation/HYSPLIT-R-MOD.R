# -----------------------------------
# HYSPLIT - Marland Analysis (3)
# Year > 2000
# Dustin Roten - Mar. 2018
# -----------------------------------

SystemType <- Sys.info()[1]

# User Alerts
Alerts <- TRUE
if(Alerts == TRUE) {do.call(file.remove, list(list.files("~/Google Drive/RAutomation/", full.names = TRUE)))} else {}

# Install functions
if(require(geosphere) == FALSE) {
  install.packages("geosphere")
  library(geosphere)
} else {require(geosphere)}

if(require(ggplot2) == FALSE) {
  install.packages("ggplot2")
  library(ggplot2)
} else {require(ggplot2)}

if(require(reshape2) == FALSE) {
  install.packages("reshape2")
  library(reshape2)
} else {require(reshape2)}

# Load custom functions
source("./SystemFiles/Custom_R_Functions.R")

#User input parameters occur below
# Ask user for previous run
PreviousRun <- readline(prompt = "Load variables from a previous run? (Y/N) - ")
if(PreviousRun == "Y" | PreviousRun == "y" | PreviousRun == "Yes" | PreviousRun == "yes" | PreviousRun == "YES") {
  
  VariablePath <- readline(prompt = "Provide the file path - ")
  
  if(file.exists(VariablePath)) {
    print(paste("Using", VariablePath, sep = " "))
    load(VariablePath)
  } else {
    print("File does not exist. Exiting script now.")
    break
  }
  
  
} else {
  
  if( interactive() ) {
    
    NAMpath <- readline(prompt = "This script uses NAM - 12km data. Include the NAM directory here - ")  
    StartYear <- as.numeric(readline(prompt = "Input Year (YYYY > 2000) - "))
    NumberOfLocations <- as.numeric(readline(prompt = "Enter the number of emissions sources - "))
    
    # initialize an empty dataframe
    LocationInformation <- data.frame()
    
    for(i in 1:NumberOfLocations) {
      
      LocationInformation[i,1] <- readline(paste(prompt = "Provide a three letter title for location", i, "-", " ", sep = " "))
      LocationInformation[i,2] <- as.numeric(readline(paste(prompt = "What is the total eGRID emission value for", LocationInformation[i,1], "in kilograms ?", " ", sep = " ")))
      LocationInformation[i,3] <- as.numeric(readline(paste(prompt = "Enter the ACTUAL number of stacks for", LocationInformation[i,1], " ", sep = " ")))
      LocationInformation[i,4] <- as.numeric(readline(paste(prompt = "What is the eGRID latitude value for", LocationInformation[i,1],"?", " ", sep = " ")))
      LocationInformation[i,5] <- as.numeric(readline(paste(prompt = "What is the eGRID longitude value for", LocationInformation[i,1],"?", " ", sep = " ")))
      LocationInformation[i,6] <- as.numeric(readline(paste(prompt = "What is the intended stack height for", LocationInformation[i,1], "?", " ", sep = " ")))
      LocationInformation[i,7] <- as.numeric(readline(paste(prompt = "What is the intended release area (m^2) for", LocationInformation[i,1], "?", " ", sep = " ")))
      LocationInformation[i,8] <- as.numeric(readline(paste(prompt = "What is the intended exhaust heat (Watts) for", LocationInformation[i,1], "?", " ", sep = " ")))
      
      
    }
    
    names(LocationInformation) <- c("Name", "eGRID_Emissions", "Number_of_Stacks",
                                    "eGRID_Lat", "eGRID_Lon", "Stack_Height",
                                    "Stack_Diameter", "Exhaust_Velocity")
    
    
    for(i in 1:nrow(LocationInformation)) {
      
      StackParams <- data.frame()
      
      for(j in 1:LocationInformation[i, 3]) {
        
        Latitude <- as.numeric(readline(paste(prompt = "Information is needed for stack", " ", j, " ", "at plant", " ", LocationInformation[i, 1], ". ", "\n",
                                              "Please provide the stack latitude (deg) - ", sep = "")))
        
        Longitude <- as.numeric(readline(paste(prompt = "Information is needed for stack", " ", j, " ", "at plant", " ", LocationInformation[i, 1], ". ", "\n",
                                               "Please provide the stack longitude (deg) - ", sep = "")))
        
        Height <- as.numeric(readline(paste(prompt = "Information is needed for stack", " ", j, " ", "at plant", " ", LocationInformation[i, 1], ". ", "\n",
                                            "Please provide the stack height (m) - ", sep = "")))
        
        EmisRate <- as.numeric(readline(paste(prompt = "Information is needed for stack", " ", j, " ", "at plant", " ", LocationInformation[i, 1], ". ", "\n",
                                              "Please provide the stack emission rate (kg/hr) - ", sep = "")))
        
        Area <- as.numeric(readline(paste(prompt = "Information is needed for stack", " ", j, " ", "at plant", " ", LocationInformation[i, 1], ". ", "\n",
                                          "Please provide the stack area (m^2) - ", sep = "")))
        
        Heat <- as.numeric(readline(paste(prompt = "Information is needed for stack", " ", j, " ", "at plant", " ", LocationInformation[i, 1], ". ", "\n",
                                          "Please provide the net stack heat (W) - ", sep = "")))
        
        temp <- c(Latitude, Longitude, Height, EmisRate, Area, Heat)
        
        StackParams <- rbind(StackParams, temp)
      }
      
      names(StackParams) <- c("Latitude", "Longitude", "Height", "EmisRate", "Area", "Heat")
      
      assign(noquote(paste(LocationInformation[i, 1], "_StackParams", sep = "")), StackParams)
      
    }
    
    
    Pollutant <- readline(prompt = "Enter pollutant name (XXXX) - ")
    
    ParticleDiameter <- readline(paste(prompt = "Information is needed about the particle species ", Pollutant, ". ", "\n",
                                       "Please provide the particle diameter (um) - ", sep = ""))
    
    ParticleDensity <- readline(paste(prompt = "Information is needed about the particle species ", Pollutant, ". ", "\n",
                                      "Please provide the particle density (g/cc) - ", sep = ""))
    
    ParticleDepoVelocity <- readline(paste(prompt = "Information is needed about the particle species ", Pollutant, ". ", "\n",
                                           "Please provide the deposition velocity (m/s) - ", sep = ""))
    
    ParticleMolecularWeight <- readline(paste(prompt = "Information is needed about the particle species ", Pollutant, ". ", "\n",
                                              "Please provide the particle molecular weight (g) - ", sep = ""))
    
    ParticleARatio <- readline(paste(prompt = "Information is needed about the particle species ", Pollutant, ". ", "\n",
                                     "Please provide the particle A-Ratio - ", sep = ""))
    
    ParticleDRatio <- readline(paste(prompt = "Information is needed about the particle species ", Pollutant, ". ", "\n",
                                     "Please provide the particle D-Ratio - ", sep = ""))
    
    ParticleHenry <- readline(paste(prompt = "Information is needed about the particle species ", Pollutant, ". ", "\n",
                                    "Please provide the 'Henry' - ", sep = ""))
    
    ParticleHenryConstant <- readline(paste(prompt = "Information is needed about the particle species ", Pollutant, ". ", "\n",
                                            "Please provide the value for Henry's Constant (M/a) - ", sep = ""))
    
    ParticleInCloud <- readline(paste(prompt = "Information is needed about the particle species ", Pollutant, ". ", "\n",
                                      "Please provide the In-cloud value (l/l) - ", sep = ""))
    
    ParticleBelowCloud <- readline(paste(prompt = "Information is needed about the particle species ", Pollutant, ". ", "\n",
                                         "Please provide the Below-Cloud value (1/s) - ", sep = ""))
    
    ParticleRadioactive <- readline(paste(prompt = "Information is needed about the particle species ", Pollutant, ". ", "\n",
                                          "Please provide the particle halflife (days) - ", sep = ""))
    
    ParticleResuspensionFactor <- readline(paste(prompt = "Information is needed about the particle species ", Pollutant, ". ", "\n",
                                                 "Please provide the pollutant resuspension factor (1/m) - ", sep = ""))
    
    Resolution <- as.numeric(readline(paste(prompt = "Please provie a resolution (in degrees) for this analysis - ")))
    
  }
  
  save.image(file = paste("HYSPLIT_Vars_", Sys.Date(), ".RData", sep = ""), version = NULL, ascii = FALSE)
  
}
    
# If a previous object file exists, the script will start from here.
# User information completed. The following organizes the pollutant's parameters
ChemicalParameters1 <- as.numeric(c(ParticleDiameter, ParticleDensity, 0))
ChemicalParameters2 <- as.numeric(c(ParticleDepoVelocity, ParticleMolecularWeight, ParticleARatio, ParticleDRatio, ParticleHenry))
ChemicalParameters3 <- as.numeric(c(ParticleHenryConstant, ParticleInCloud, ParticleBelowCloud))
ChemicalParameters4 <- as.numeric(ParticleRadioactive)
ChemicalParameters5 <- as.numeric(ParticleResuspensionFactor)


# Constructing the time management dataframe
MonthNames <- c("jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec")
DaysInMonth <- c(31, if (StartYear %% 4 == 0) {29} else{28}, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
MonthData <- data.frame(MonthNames, DaysInMonth)


# Constructing a vector of meteorology file names (NAM-12km)
MeteorologyFileNames <- NULL
c <- 1
for(a in 1:12) {
  
  for(b in 1:MonthData[a,2]) {
    
    MeteorologyFileNames[c] <- paste(StartYear, if(a <= 9) {"0"} else {}, a, if(b <= 9) {"0"} else {}, b, "_nam12", sep = "")
    c <- c + 1
    
  }
}

# Do work in the SystemFiles directory
setwd("SystemFiles")
dir.create("Archive")


# LOOP MODEL TYPE (A-F)
ModelType <- c("A", "B", "C", "D", "E")

# A- eGRID-Only Model
# B- Inclusion of Stack Height
# C- Inclusion of Stack Diameter
# D- Inclusion of Exhaust Velocity
# E- "Full" Model


### Constructing the CONTROL file for HYSPLIT ###

# Model type to be used
for(z in 1:length(ModelType)) {     # Begins the "Model Type" loop
  
  ModType <- ModelType[z]
  
  # The *_StackParams file will be needed for each point source.
  for(i in 1:nrow(LocationInformation)) {     # Starts specific "Stack Information" for each location
    
    eval(parse(text = paste("StackInfo", "<- ", LocationInformation[i,1], "_StackParams", sep = "")))
    
    # This will generate the parent data frame that will be continuously appended. Each point source and model type will receive it's own file. XXX_X.
    
    ParentFileName <- paste(LocationInformation[i,1], "_", ModType, sep = "")
    ColumnNames <- c("DA", "HR", "LAT", "LON", paste(Pollutant))
    ParentDataFrame <- as.data.frame(setNames(replicate(6, numeric(0), simplify = FALSE), ColumnNames))
    
    eval(parse(text = paste(write.table(ParentDataFrame, ParentFileName, row.names = FALSE, col.names = TRUE))))
    
    for(q in 1:12) {     # Starts the loop for each month
      
      for(m in 1:MonthData[q,2]) {     # Starts the loop for each day of the month
        
        cat(
          
          paste(StartYear - 2000, q, m, 00, collapse = " "),"\n",
          if(ModType != "E") {1} else {LocationInformation[i,3]}, "\n",
          
          sep = "", file = "CONTROL"
          
        )
        
        # This break in the CONTROL file is where multiple stacks (if applicible) get added.
        # This is achieved by appending the portion of the CONTROL file generated from the above code.
        
        if(ModType == "A") {
          
            # Run the simplified model - All parameters are 0
            line <- paste(LocationInformation[i,4], LocationInformation[i,5], 0, (LocationInformation[i,2]/sum(DaysInMonth))/24, 0, 0, sep = " ")
            write(line, file = "CONTROL", append = TRUE)
          
        } else if(ModType == "B") {
          
              # Insert a single stack at eGRID location with an assigned HEIGHT and EMISSION RATE
              line <- paste(LocationInformation[i,4], LocationInformation[i,5], LocationInformation[i,6], (LocationInformation[i,2]/sum(DaysInMonth))/24, 0, 0, sep = " ")
              write(line, file = "CONTROL", append = TRUE)
          
        } else if(ModType == "C") {
        
              # Insert a single stack at eGRID location with an assigned DIAMETER and EMISSION RATE
              line <- paste(LocationInformation[i,4], LocationInformation[i,5], 0, (LocationInformation[i,2]/sum(DaysInMonth))/24, LocationInformation[i,7], 0, sep = " ")
              write(line, file = "CONTROL", append = TRUE)
          
        } else if(ModType == "D") {
          
              # Insert a single stack at eGRID location with an assigned EXHAUST TEMPERATURE and EMISSION RATE
              line <- paste(LocationInformation[i,4], LocationInformation[i,5], 0, (LocationInformation[i,2]/sum(DaysInMonth))/24, 0, LocationInformation[i,8], sep = " ")
              write(line, file = "CONTROL", append = TRUE)
          
        } else if(ModType == "E") {
          
              # Apply ALL PARAMETERS to each stack present at the location of interest
              for(j in 1:LocationInformation[i,3]) {
            
                  line <- paste(StackInfo[j,1], StackInfo[j,2], StackInfo[j,3], StackInfo[j,4], StackInfo[j,5], StackInfo[j,6], sep = " ")
                  write(line, file = "CONTROL", append = TRUE)
            
          }
          
      } # This closes StackInfo
        
        
        # The remaining parameters of the CONTROL file are added here by appending the portion of the CONTROL file generated above.
        
        y <- m + sum(MonthData[1:q-1, 2])     # The value of y selects the meteorology file to be used.
        
        cat(
          
          24, "\n",     # Total run time (hrs)
          0, "\n",      # Method of vertical motion
          20000, "\n",  # Top of the model (m)
          3, "\n",      # Number of NAM12km files loaded in
          
          paste(NAMpath), "\n",
          paste(if(q == 1 & m == 1) {paste(StartYear-1, "1231_nam12", sep = "")} else {MeteorologyFileNames[y-1]}), "\n",
          
          paste(NAMpath), "\n",
          paste(MeteorologyFileNames[y]), "\n",
          
          paste(NAMpath), "\n",
          paste(if(q == 12 & m == 31) {paste(StartYear+1, "0101_nam12", sep = "")} else {MeteorologyFileNames[y+1]}), "\n",
          
          1, "\n",      # Number of pollutants
          Pollutant, "\n",
          (LocationInformation[i,2]/sum(MonthData[,2]))/24, "\n",    # This is an hourly rate
          24, "\n",
          paste(StartYear - 2000, q, m, 0, 0, collapse = " "), "\n",
          1, "\n",      # Number of grids = number of pollutants
          paste(round(mean(StackInfo[,1]), 5), round(mean(StackInfo[,2]), 5), collapse = " "), "\n",
          paste( c(0.05, 0.05), collapse = " "), "\n",     # Resolution of the grid (lat, lon)
          paste( c(80.0, 80.0), collapse = " "), "\n",     # Size of the display grid (lat, lon)
          "./", "\n",    # Save the files here
          paste(LocationInformation[i,1], "-", ModType, "-", StartYear - 2000, "-", q, "-", m, sep = ""), "\n",    # This is the individual file name
          1, "\n",
          20000, "\n", # Vertical levels, top of model
          paste(StartYear - 2000, q, m, 0, 0, collapse = " "), "\n",
          
          # This conditionals adjusts the model stop date at the end of each month
          paste(        
            
            (if(q == 12 & m == MonthData[12,2]) {temp <- as.numeric((StartYear + 1)) - 2000} else {StartYear - 2000}),
            
            (if(m <= (MonthData[q,2]-1)) {q}
             else if(m == MonthData[q,2] & q != 12) {q+1}
             else if(q == 12 & m == MonthData[12,2]) {1}),
            
            (if (m <= (MonthData[q,2]-1)) {m+1} else {1}),
            00, 00, collapse = " "), "\n",
          # END stop date management
          
          paste( c(00, 24, 00), collapse = " "), "\n",     # Analysis method - averaging
          1, "\n",      # Number of particles for deposition
          paste(ChemicalParameters1, collapse = " "), "\n",
          paste(ChemicalParameters2, collapse = " "), "\n",
          paste(ChemicalParameters3, collapse = " "), "\n",
          paste(ChemicalParameters4, collapse = " "), "\n",
          paste(ChemicalParameters5, collapse = " "), "\n",
          
          sep = "", file = "CONTROL", append = TRUE
          
        )
        
        # Moves CONTROL file into Archive
        file.copy("CONTROL",
                  paste("./Archive/", LocationInformation[i,1], "_", ModType, "_", q, "_", m, "_", StartYear, "_CONTROL", sep = ""),
                  overwrite = TRUE
                  )
        
        # EMITIMES file begins here
        if(ModType == "A") {
          
            cat(
              paste("YYYY MM DD HH   DURATION(hhhh) #RECORDS", sep = ""),"\n",
              paste("YYYY MM DD HH MM DURATION(hhmm) LAT LON HGT(m) RATE(/h) AREA(m2) HEAT(w)"), "\n",
              paste(StartYear, q, m, 0, 9999, 1, collapse = " "), "\n",
              sep = "", file = "EMITIMES"
            )
          
            # All parameters are 0
            line <- paste(StartYear, q, m, 0, 0, 2400, LocationInformation[i,4], LocationInformation[i,5], 0, (LocationInformation[i,2]/sum(DaysInMonth))/24, 0, 0, sep = " ")
            write(line, file = "EMITIMES", append = TRUE)
            
          } else if(ModType == "B") {
              
            cat(
              paste("YYYY MM DD HH   DURATION(hhhh) #RECORDS", sep = ""),"\n",
              paste("YYYY MM DD HH MM DURATION(hhmm) LAT LON HGT(m) RATE(/h) AREA(m2) HEAT(w)"), "\n",
              paste(StartYear, q, m, 0, 9999, 1, collapse = " "), "\n",
              sep = "", file = "EMITIMES"
            )
            
              # Insert a single stack at eGRID location with an assigned HEIGHT and EMISSION RATE to EMITIMES file
              line <- paste(StartYear, q, m, 0, 0, 2400, LocationInformation[i,4], LocationInformation[i,5], LocationInformation[i,6], (LocationInformation[i,2]/sum(DaysInMonth))/24, 0, 0, sep = " ")
              write(line, file = "EMITIMES", append = TRUE)
            
          } else if(ModType == "C") {

            cat(
              paste("YYYY MM DD HH   DURATION(hhhh) #RECORDS", sep = ""),"\n",
              paste("YYYY MM DD HH MM DURATION(hhmm) LAT LON HGT(m) RATE(/h) AREA(m2) HEAT(w)"), "\n",
              paste(StartYear, q, m, 0, 9999, 1, collapse = " "), "\n",
              sep = "", file = "EMITIMES"
            )
            
              # Insert a single stack at eGRID location with an assigned DIAMETER and EMISSION RATE to EMITIMES file            
              line <- paste(StartYear, q, m, 0, 0, 2400, LocationInformation[i,4], LocationInformation[i,5], 0, (LocationInformation[i,2]/sum(DaysInMonth))/24, LocationInformation[i,7], 0, sep = " ")
              write(line, file = "EMITIMES", append = TRUE)
            
          } else if(ModType == "D") {
            
            cat(
              paste("YYYY MM DD HH   DURATION(hhhh) #RECORDS", sep = ""),"\n",
              paste("YYYY MM DD HH MM DURATION(hhmm) LAT LON HGT(m) RATE(/h) AREA(m2) HEAT(w)"), "\n",
              paste(StartYear, q, m, 0, 9999, 1, collapse = " "), "\n",
              sep = "", file = "EMITIMES"
            )
            
              # Insert a single stack at eGRID location with an assigned 
              line <- paste(StartYear, q, m, 0, 0, 2400, LocationInformation[i,4], LocationInformation[i,5], 0, (LocationInformation[i,2]/sum(DaysInMonth))/24, 0, LocationInformation[i,8], sep = " ")
              write(line, file = "EMITIMES", append = TRUE)
            
          } else if(ModType == "E") {
            
              cat(
              
                  paste("YYYY MM DD HH   DURATION(hhhh) #RECORDS", sep = ""),"\n",
                  paste("YYYY MM DD HH MM DURATION(hhmm) LAT LON HGT(m) RATE(/h) AREA(m2) HEAT(w)"), "\n",
                  paste(StartYear, q, m, 0, 9999, LocationInformation[i,3], collapse = " "), "\n",
                  sep = "", file = "EMITIMES"
              
              )
            
            for(j in 1:LocationInformation[i,3]) {
              
              line <- paste(StartYear, q, m, 0, 0, 2400, StackInfo[j,1], StackInfo[j,2], StackInfo[j,3], StackInfo[j,4], StackInfo[j,5], StackInfo[j,6], sep = " ")
              write(line, file = "EMITIMES", append = TRUE)
              
            }
            
          } # This closes the conditional EMITIMES file generation
        
        # Move EMITIMES file to Archive folder
        file.copy("EMITIMES",
                  paste("./Archive/", LocationInformation[i,1], "_", ModType, "_", q, "_", m, "_", StartYear, "_EMITIMES", sep = ""),
                  overwrite = TRUE
        )
        
    
        # Run the HYSPLIT model to produce a binary file output. Convert this to an ASCII file to be used for the analysis.
        if(SystemType == "Windows") {
          system2("./hycs_std.exe")
          system2("./con2asc.exe", paste(LocationInformation[i,1], "-", ModType, "-", StartYear - 2000, "-", q, "-", m, sep = ""))
        } else {
          system2("./hycs_std")
          system2("./con2asc", paste(LocationInformation[i,1], "-", ModType, "-", StartYear - 2000, "-", q, "-", m, sep = ""))
          
          file.copy("MESSAGE",
                    paste("./Archive/", LocationInformation[i,1], "_", ModType, "_", q, "_", m, "_", StartYear, "_MESSAGE", sep = ""),
                    overwrite = TRUE
          )
          
          if(file.exists("WARNING") == TRUE) {
          
              file.copy("WARNING",
                    paste("./Archive/", LocationInformation[i,1], "_", ModType, "_", q, "_", m, "_", StartYear, "_WARNING", sep = ""),
                    overwrite = TRUE
              )
          } else {}
          
        }
        
        # The con2asc appends each output ASCII file with an unwanted delimiter in the file name. That is fixed here.
        # The original binary file is also overwritten.
        file.rename(list.files(pattern = "_00", full.names = TRUE), paste(LocationInformation[i,1], "-", ModType, "-", StartYear - 2000, "-", q, "-", m, sep = ""))
        
        # The single ASCII file is then appended to the large file.
        # 'temp' is a temporary object that reads in the ASCII file
        CurrentCSV <- read.csv(paste(LocationInformation[i,1], "-", ModType, "-", StartYear - 2000, "-", q, "-", m, sep = ""), header = TRUE, sep = "")
        names(CurrentCSV) <- ColumnNames
        write.table(CurrentCSV, ParentFileName, append = TRUE, row.names = FALSE, col.names = FALSE)
        
        # The single ASCII file is then deleted in order to save space.
        file.remove(paste(LocationInformation[i,1], "-", ModType, "-", StartYear - 2000, "-", q, "-", m, sep = ""))
        
      }     # Closes the day
    }     # Closes the Month
    
    if(Alerts == TRUE) {
      write.table(Sys.time(), file = paste("RawData_", LocationInformation[i,1], "_", ModType, ".tsv", sep = ""), col.names = FALSE, row.names = FALSE)
      file.rename(from = paste("RawData_", LocationInformation[i,1], "_", ModType, ".tsv", sep = ""),
                  to = paste("~/Google Drive/RAutomation/RawData_", LocationInformation[i,1], "_", ModType, ".tsv", sep = ""))
    } else{}
    
  }     # Closes LocationInformation
}     # Closes ModelType


##### The metrics follow here #####
for(d in 1:nrow(LocationInformation)) {
  
    # Model2 is reserved by default for the "A" scenario (All parameters included)
    Model2 <- as.data.frame(read.table(paste(LocationInformation[d,1], "_", "A", sep = ""), header = TRUE, sep = "")[1:5])
    Model2$DA <- Model2$DA - 1
    Model2$DA[Model2$DA == 0] <- (c-1)
  
    # The loop below steps through each of the other models and compares them to "E"
    for(e in 1:length(ModelType)) {
    
        if(ModelType[e] != "A") {
      
            Model1 <- read.table(paste(LocationInformation[d,1], "_", ModelType[e], sep = ""), header = TRUE, sep = "")[1:5]
            Model1$DA <- Model1$DA - 1
            Model1$DA[Model1$DA == 0] <- (c-1)
      
            Metrics <- data.frame()
      
            MRSMeasure = NULL
            COMMeasure = NULL
            AngleMeasure = NULL
            STDAngleMeasure = NULL
            Origin = NULL
      
            # METRICS START HERE!
            for(f in 1:(c-1) ) {     # Here, the model is incremented for each day and all metrics are used (day variable: "f")
        
              temp1 <- subset(Model1, DA == f)
              temp2 <- subset(Model2, DA == f)
        
              DayModel1 <- ShiftToOrigin("S", temp1, round(mean(LocationInformation[d,4]), 5), round(mean(LocationInformation[d,5]), 5))
              DayModel2 <- ShiftToOrigin("S", temp2, round(mean(LocationInformation[d,4]), 5), round(mean(LocationInformation[d,5]), 5))
        
        # SHIFT TO ORIGIN HERE
        
        Matrix_Model2_Dispersion <- GridDispersions2(DayModel2, DayModel1, Resolution, 1)
        Matrix_Model1_Dispersion <- GridDispersions2(DayModel2, DayModel1, Resolution, 2)
        Origin <- LocateOrigin(DayModel2, DayModel1, Resolution, Day = f)
        
        MRSMeasure[f] <- (1/(2*sum(Matrix_Model2_Dispersion)))*sum(abs(Matrix_Model2_Dispersion - Matrix_Model1_Dispersion))*100
        
        if(MRSMeasure[f] > 100) {
          
            flag <- 0
            for(Month in 1:12) {
                if((sum(DaysInMonth[1:Month]) - f) > 0 && flag == 0) {
                      print(Month)
                      MON <- Month
                      DAY <- f-sum(DaysInMonth[1:(Month-1)])
                      flag <- 1
            } else {}
          }
          
            message <- paste("Error", "MRSMeasure =", MRSMeasure[f], "\n",
                             "Location:", " ", LocationInformation[d,1], "\n",
                             "Day:", " ", f, "\n", sep = " ")
            write(message, file = "ERROR_MESSAGES.txt", append = TRUE)
            file.copy("ERROR_MESSAGES.txt", "~/Google Drive/RAutomation/ERROR_MESSAGES.txt", overwrite = TRUE)
          
            file.copy(paste("./Archive/",  LocationInformation[d,1], "_", ModelType[e], "_", MON, "_", DAY, "_", StartYear, "_CONTROL", sep = ""),
                      paste("~/Google Drive/RAutomation/", LocationInformation[d,1], "_", ModelType[e], "_", MON, "_", DAY, "_", StartYear, "_CONTROL", sep = ""),
                      overwrite = TRUE
            )
          
            file.copy(paste("./Archive/",  LocationInformation[d,1], "_", ModelType[e], "_", MON, "_", DAY, "_", StartYear, "_EMITIMES", sep = ""),
                      paste("~/Google Drive/RAutomation/", LocationInformation[d,1], "_", ModelType[e], "_", MON, "_", DAY, "_", StartYear, "_EMITIMES", sep = ""),
                      overwrite = TRUE
            )
            
            file.copy(paste("./Archive/",  LocationInformation[d,1], "_", ModelType[e], "_", MON, "_", DAY, "_", StartYear, "_MESSAGE", sep = ""),
                      paste("~/Google Drive/RAutomation/", LocationInformation[d,1], "_", ModelType[e], "_", MON, "_", DAY, "_", StartYear, "_MESSAGE", sep = ""),
                      overwrite = TRUE
            )
              
            file.copy(paste("./Archive/",  LocationInformation[d,1], "_", ModelType[e], "_", MON, "_", DAY, "_", StartYear, "_WARNING", sep = ""),
                      paste("~/Google Drive/RAutomation/", LocationInformation[d,1], "_", ModelType[e], "_", MON, "_", DAY, "_", StartYear, "_WARNING", sep = ""),
                      overwrite = TRUE)
          
          
        } else {}
        
        # "Spatial" Matrices
        Melted_Model2_Dispersion <- melt(Matrix_Model2_Dispersion)
        Melted_Model1_Dispersion <- melt(Matrix_Model1_Dispersion)
        
        Melted_Model2_Dispersion <- subset(Melted_Model2_Dispersion, Melted_Model2_Dispersion$value != 0)
        Melted_Model1_Dispersion <- subset(Melted_Model1_Dispersion, Melted_Model1_Dispersion$value != 0)
        
        Melted_Model2_Dispersion$Var1 <- Melted_Model2_Dispersion$Var1 - Origin[1]
        Melted_Model2_Dispersion$Var2 <- Melted_Model2_Dispersion$Var2 - Origin[2]
        Melted_Model1_Dispersion$Var1 <- Melted_Model1_Dispersion$Var1 - Origin[1]
        Melted_Model1_Dispersion$Var2 <- Melted_Model1_Dispersion$Var2 - Origin[2]
        
        names(Melted_Model2_Dispersion) <- c("Y", "X", "CO2")
        names(Melted_Model1_Dispersion) <- c("Y", "X", "CO2")
        
        # Center of Mass Calculation
        x1 <- sum(Melted_Model2_Dispersion$X * Melted_Model2_Dispersion$CO2)/sum(Melted_Model2_Dispersion$CO2)
        y1 <- sum(Melted_Model2_Dispersion$Y * Melted_Model2_Dispersion$CO2)/sum(Melted_Model2_Dispersion$CO2)
        x2 <- sum(Melted_Model1_Dispersion$X * Melted_Model1_Dispersion$CO2)/sum(Melted_Model1_Dispersion$CO2)
        y2 <- sum(Melted_Model1_Dispersion$Y * Melted_Model1_Dispersion$CO2)/sum(Melted_Model1_Dispersion$CO2)
        
        COMMeasure[f] <- 111*Resolution*sqrt((x2 - x1)^2 + (y2 - y1)^2)
        
        # Mean Angle Calculation
        Angle1 <- if( (180/pi)*atan2(y1, x1) < 0 ) {360 + (180/pi)*atan2(y1, x1)} else {(180/pi)*atan2(y1, x1)}
        Angle2 <- if( (180/pi)*atan2(y2, x2) < 0 ) {360 + (180/pi)*atan2(y2, x2)} else {(180/pi)*atan2(y2, x2)}
        
        AngleMeasure[f] <- if(abs(Angle1 - Angle2) > 180) {360 - abs(Angle1 - Angle2)} else {abs(Angle1 - Angle2)}
        
        # Standard Deviation Calculation
        NormalizedAxis_Melted_Model2_Dispersion <- data.frame(
          Melted_Model2_Dispersion$X*sin(-Angle1*pi/180) + Melted_Model2_Dispersion$Y*cos(-Angle1*pi/180),
          Melted_Model2_Dispersion$X*cos(-Angle1*pi/180) - Melted_Model2_Dispersion$Y*sin(-Angle1*pi/180),
          Melted_Model2_Dispersion$CO2
        )
        names(NormalizedAxis_Melted_Model2_Dispersion) <- c("Y", "X", "CO2")
        
        NormalizedAxis_Melted_Model1_Dispersion <- data.frame(
          Melted_Model1_Dispersion$X*sin(-Angle2*pi/180) + Melted_Model1_Dispersion$Y*cos(-Angle2*pi/180),
          Melted_Model1_Dispersion$X*cos(-Angle2*pi/180) - Melted_Model1_Dispersion$Y*sin(-Angle2*pi/180),
          Melted_Model1_Dispersion$CO2
        )
        names(NormalizedAxis_Melted_Model1_Dispersion) <- c("Y", "X", "CO2")
        
        STDAngle1 <- sd((180/pi)*atan2(NormalizedAxis_Melted_Model2_Dispersion$Y, NormalizedAxis_Melted_Model2_Dispersion$X))
        STDAngle2 <- sd((180/pi)*atan2(NormalizedAxis_Melted_Model1_Dispersion$Y, NormalizedAxis_Melted_Model1_Dispersion$X))
        
        STDAngleMeasure[f] <- abs(STDAngle1 - STDAngle2)
        
      }     # Closes the daily loop
      
      # Write output file here
      Metrics <- data.frame(c(1:(c-1)), MRSMeasure, AngleMeasure, STDAngleMeasure, COMMeasure)
      names(Metrics) <- c("Day", "MRS", "MeanAngle", "VarAngle", "CenterOfMass")
      write.csv(Metrics, paste(LocationInformation[d,1], "_", ModelType[e], "_", StartYear, "_", Resolution, sep = ""))
      
    } else {}     # Closes the conditional != "A" statement
    
    if(Alerts == TRUE) {
      write.table(Sys.time(), file = paste("Analysis_", LocationInformation[d,1], "_", ModelType[e], ".tsv", sep = ""), col.names = FALSE, row.names = FALSE)
      file.rename(from = paste("Analysis_", LocationInformation[d,1], "_", ModelType[e], ".tsv", sep = ""),
                  to = paste("~/Google Drive/RAutomation/Analysis_", LocationInformation[d,1], "_", ModelType[e], ".tsv", sep = ""))
    } else{}
    
  }    # Closes each model
}    # Closes each location


##### The cleaning process begins here #####
dir.create(paste("../HYSPLIT-Results-", StartYear, sep = ""))

for(s in 1:length(ModelType)) {
  
  file.copy(paste("Results", ModelType[s], ".jpg", sep = ""), paste("../HYSPLIT-Results-", StartYear, sep = ""))
  file.remove(paste("Results", ModelType[s], ".jpg", sep = ""))
  
  for(u in 1:nrow(LocationInformation)) {
    
    file.copy(paste(LocationInformation[u,1], "_", ModelType[s], sep = ""), paste("../HYSPLIT-Results-", StartYear, sep = ""))
    file.remove(paste(LocationInformation[u,1], "_", ModelType[s], sep = ""))
    
    file.copy(paste(LocationInformation[u,1], "_", ModelType[s], "_", StartYear, "_", Resolution, sep = ""), paste("../HYSPLIT-Results-", StartYear, sep = ""))
    file.remove(paste(LocationInformation[u,1], "_", ModelType[s], "_", StartYear, "_", Resolution, sep = ""))
    
  }
  
}


print("disregard warnings above") 
setwd(paste("../HYSPLIT-Results-", StartYear, sep = ""))