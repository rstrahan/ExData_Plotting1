library(data.table)
library(lubridate)

prepareData <- function() {
    # set locations
    url <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
    zipfile <- "./household_power_consumption.zip"
    datafile <- "./household_power_consumption.txt"
    # download and decompress the data file only if not already in the working directory
    if (! file.exists(datafile)) {
        if (! file.exists(zipfile)) {
            print("Downloading data zip file")
            download.file(url,zipfile, method="curl")
        }
        print("Unzipping data file")
        unzip(zipfile)
    }
    # read the file into a data table
    print("Loading data")
    data <- read.csv(datafile, sep=";", na.strings=c("?"))
    print("Preparing data")
    # Convert Date column from character to POSIXct class - parse as date/month/year
    data$Date = dmy(data$Date)
    # subset only the dates we care about - 2007-02-01 and 2007-02-02
    data <- subset(data, Date >= ymd("2007-02-01") & Date <= ymd("2007-02-02"))
    # Convert Time column from character to POSIXct class
    data$Time = hms(data$Time)
    # Combine Date and Time
    data$DateTime = data$Date + data$Time
    return(data)
}

data <- prepareData()

# create png graphics device
file <- "plot4.png"
cat("Creating PNG file: ",file)
png(filename=file, width=480, height=480, units="px")
# create 2x2 grid for plots
par(mfrow=c(2,2))
with(data, plot(DateTime,Global_active_power, type="l", xlab="", ylab="Global Active Power"))
with(data, plot(DateTime,Voltage, type="l", xlab="datetime", ylab="Voltage"))
with(data, {
    plot(DateTime,Sub_metering_1, type="n", xlab="", ylab="Energy sub metering")
    lines(DateTime,Sub_metering_1,col="black")
    lines(DateTime,Sub_metering_2,col="red")
    lines(DateTime,Sub_metering_3,col="blue")
    legend("topright", lty=1, bty="n", col=c("black","red","blue"), legend=c("Sub_metering_1","Sub_metering_2","Sub_metering_3"))
})
with(data, plot(DateTime,Global_reactive_power, type="l", xlab="datetime"))
dev.off()
