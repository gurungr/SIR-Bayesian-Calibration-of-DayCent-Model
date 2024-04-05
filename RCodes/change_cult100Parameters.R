changeParms_cult100<- function(params){
	# Author: Ram Gurung (1/28/2016)
	# ARGUMENTS:
	# params        a numerical value for cult effect for tillage event K
	culteffK_value <- as.numeric(params[,ncol(params)])
	cult100 <- readLines("cult.100")
	tillages <- c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K")
	till_adjust <- c(0.0144, 0.1156, 0.1878, 0.2678, 0.3167, 0.3911, 0.4733, 0.5622, 0.6300, 0.9711, 1.0)
	for(i in 1:length(tillages)){
		till.pos <- grep(glob2rx(paste(tillages[i], "*", sep = "")), cult100)
		culteff <- round(1 + (culteffK_value -1)*till_adjust[i], 4)
		cult100[till.pos + 8]  <- paste(culteff, "           'CLTEFF(1)'", sep="")
		cult100[till.pos + 9]  <- paste(culteff, "           'CLTEFF(2)'", sep="")
		cult100[till.pos + 11] <- paste(culteff, "           'CLTEFF(4)'", sep="")
	}
	#
	# remove cult.100 file
	if(file.exists("cult.100")){
		file.remove("cult.100")
	}
	con_cult100 <- file("cult.100", open='w')
	writeLines(cult100, con_cult100)
	close(con_cult100)
	return(NULL)
}
