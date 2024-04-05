changeParms_fix100<- function(params){
	# Author: Ram Gurung (4/30/2018)
	# ARGUMENTS:
	# fix100      a character vector of fix.100 using readLines()
	# parms        a data.frame object with 1 row with new parameters for the fix.100
	#              and column names matching the fix.100 parameter names
	# remove last columns, which is a tillage multiplier not a fix.100 parameter
	params <- params[,-ncol(params)]
	fix100 <- readLines("fix.100")
	params_name <- names(params)
	params_value <- as.numeric(params)
	for(i in 1:length(params_name)){
		parms.pos <- grep(glob2rx(paste("*", params_name[i], "*", sep = "")), fix100)
		fix100[parms.pos] <- paste(params_value[i], "        ", params_name[i], sep="")
		#print(fix100[parms.pos])
	}
	#
	# remove fix.100 file
	if(file.exists("fix.100")){
		file.remove("fix.100")
	}
	#
	con_fix100 <- file("fix.100", open='w')
	writeLines(fix100, con_fix100)
	close(con_fix100)
	return(NULL)
}
