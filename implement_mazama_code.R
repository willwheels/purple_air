
library(AirSensor)

# Set the archiveBaseUrl so we can get a 'pas' object
setArchiveBaseUrl("http://data.mazamascience.com/PurpleAir/v1")

# Load the default 'pas' (today for the entire US)



pas <- pas_load(datestamp = "20211231", archival = TRUE)



# Use the default archiveDir unless it is already defined
if ( !exists("archiveDir") ) {
  archiveDir <- here::here("data")
}

dir.create(archiveDir, recursive = TRUE)


# Save it in our archive directory
save(pas, file = file.path(archiveDir, "pas.rda"))

# Examine archive directory:
list.files(file.path(archiveDir))

# ----- Create PAT objects -----------------------------------------------------

# Get all the deviceDeploymentIDs
pas_ids <- pas_getDeviceDeploymentIDs(pas)



# Specify time range
startdate <- "2015-01-01"
enddate <- "2021-12-31"
timezone <- "America/Los_Angeles"



# Create an empty List to store things
patList <- list()

# Initialize counters
idCount <- length(pas_ids)
count <- 0 
successCount <- 0

# Start the clock!
ptm <- proc.time()

# Loop over all ids and get data (This might take a while.)
for (id in pas_ids[1:10]) {
  
  count <- count + 1
  print(sprintf("Working on %s (%d/%d) ...", id, count, idCount))
  
  # Use a try-block in case you get "no data" errors
  result <- try({
    
    # Here we show the full function signature so you can see all possible arguments
    patList[[id]] <- pat_createNew(
      id = id,
      label = NULL,        # not needed if you have the id
      pas = pas,
      startdate = startdate,
      enddate = enddate,
      timezone = timezone,
      baseUrl = "https://api.thingspeak.com/channels/",
      verbose = FALSE
    )
    successCount <- successCount + 1
    
  }, silent = FALSE)
  
  if ( "try-error" %in% class(result) ) {
    print(geterrmessage())
  }
  
}

# Stop the clock
proc.time() - ptm

### 1.8 hours for 10 gd sensors!


# How many did we get?
print(sprintf("Successfully created %d/%d pat objects.", successCount, idCount))

# Save it in our archive directory
save(patList, file = file.path(archiveDir, "patList.rda"))

# ----- Evaluate patList -------------------------------------------------------

# We can use sapply() to apply a function to each element of the list
sapply(patList, function(x) { return(x$meta$label) })

# How big is patList in memory?
print(object.size(patList), units = "MB")

# How big patList.rda on disk (as compressed binary) 
fileSize <- file.size(file.path(archiveDir, "patList.rda"))
sprintf("%.1f Mb", fileSize/1e6)

