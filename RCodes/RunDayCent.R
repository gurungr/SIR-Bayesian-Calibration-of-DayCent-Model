RunDC <- function(x){
	#===================================================================================================================
	#  FILENAME:  RunDayCent.R
	#
	#  AUTHOR:    Ram B. Gurung
	#             Natural Resource Ecology Laboratory
	#             Colorado State University
	#             Fort Collins CO, 80528
	#             USA
	#===================================================================================================================
	result <- tryCatch({
		# DayCent executiable files 
		filepath_exe <- paste("<linux directory>", "/DayCent/DDcentEVI", sep = "")
		#===================================================================================
		params <- X[X$SampleID == x, -1]
		#===================================================================================
		setwd(sitePath)
		#===============================================================================================================
		# Change fix.100 with given parameters
		changeParms_fix100(params = params)
		#===============================================================================================================
		# Change cult.100 with given parameters
		changeParms_cult100(params = params)
		#===============================================================================================================
		#   Run equilibrium and generate .dsa binary site file and .lis file 
		eq <- "broadbalk_eq"
		file.remove(paste(eq,".dsa",sep=""))
		file.remove(paste(eq,".log",sep=""))
		eq.sys.cmnd <- paste(filepath_exe, " -s ", eq, " -W 1 ", eq, ".dsa >& ", eq, ".log", sep = "")
		system(command = eq.sys.cmnd, intern = F, wait = T) 
		#===============================================================================================================
		# Read Log Files and check for Execution success
		logLines <- readLines(paste(eq, ".log", sep = ""))
		last.line.txt <- logLines[length(logLines)]
		flag2 <- grepl("Execution success", last.line.txt)
		if(!flag2){
			stop(paste("DDCent Failed for:-", eq, sep = ""))
		}
		rm(flag2, logLines, last.line.txt, eq.sys.cmnd)
		#===============================================================================================================
		# Run base schedule file
		base <- "broadbalk_base"
		file.remove(paste(base,".dsa",sep=""))
		file.remove(paste(base,".log",sep=""))
		base.sys.cmnd <- paste(filepath_exe, " -s ", base, " -R 1 --site ", eq, ".dsa -W 1 ", base, ".dsa >& ", base, ".log", sep = "")
		system(command = base.sys.cmnd, intern = F, wait = T) 
		#===============================================================================================================
		# Read Log Files and check for Execution success
		logLines <- readLines(paste(base, ".log", sep = ""))
		last.line.txt <- logLines[length(logLines)]
		flag2 <- grepl("Execution success", last.line.txt)
		if(!flag2){
			stop(paste("DDCent Failed for:-", base, sep = ""))
		}
		rm(flag2, logLines, last.line.txt, base.sys.cmnd)
		#===============================================================================================================
		trt1 <- "broadbalk_WWW_FYM2+straw"
		trt1.sys.cmnd <- paste(filepath_exe, " -s ", trt1, " -R 1 --site ", base, ".dsa ",
								" -t ", trt1, ".lis -v 'somsc' >& ", trt1, ".log", sep = "")
		system(command = trt1.sys.cmnd, intern = F, wait = T)
		#===============================================================================================================
		# Read Log Files and check for Execution success
		logLines <- readLines(paste(trt1, ".log", sep = ""))
		last.line.txt <- logLines[length(logLines)]
		flag2 <- grepl("Execution success", last.line.txt)
		if(!flag2){
			stop(paste("DDCent Failed for:-", trt, sep = ""))
		}
		rm(flag2, logLines, last.line.txt, trt1.sys.cmnd)
		lis1 <- read.table(paste(trt1, ".lis", sep = ""), skip = 2, header = F)
		names(lis1) <- c("year", "somsc")
		lis1$schedule <- paste(trt1, ".sch", sep = "")
		#===============================================================================================================
		trt2 <- "broadbalk_WWW_N0+straw"
		trt2.sys.cmnd <- paste(filepath_exe, " -s ", trt2, " -R 1 --site ", base, ".dsa ",
								" -t ", trt2, ".lis -v 'somsc' >& ", trt2, ".log", sep = "")
		system(command = trt2.sys.cmnd, intern = F, wait = T)
		#===============================================================================================================
		# Read Log Files and check for Execution success
		logLines <- readLines(paste(trt2, ".log", sep = ""))
		last.line.txt <- logLines[length(logLines)]
		flag2 <- grepl("Execution success", last.line.txt)
		if(!flag2){
			stop(paste("DDCent Failed for:-", trt, sep = ""))
		}
		rm(flag2, logLines, last.line.txt, trt2.sys.cmnd)
		lis2 <- read.table(paste(trt2, ".lis", sep = ""), skip = 2, header = F)
		names(lis2) <- c("year", "somsc")
		lis2$schedule <- paste(trt2, ".sch", sep = "")
		#===============================================================================================================
		# Read Log Files and check for Execution success
		somsc <- rbind(lis1, lis2)
		SOC <- merge(somsc[, c("schedule", "year", "somsc")], 
					 MeasSOC[, c("schedule", "year", "measSOC")], 
					 by = c("schedule", "year"))
		SOC$resi <- (log(SOC$somsc) - log(SOC$measSOC))  # kg C/m^2
		sigma1 <- sqrt(mean(SOC$resi^2))# kg C/m^2
		n1 <- nrow(SOC)
		lLkhd <- -n1*log(sigma1)-(1/(2*sigma1^2))*sum(SOC$resi^2)
		
		rtn.val <- data.frame("SampleID" = x, "llkhd" = lLkhd)
	}, error = function(err){
		rtn.val <- data.frame("SampleID" = x, "llkhd" = NULL)
	})
	return(result)
}
