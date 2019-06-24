URL <- 'https://s3.amazonaws.com/athena-downloads/drivers/AthenaJDBC41-1.0.1.jar'
fil <- basename(URL)

if (!file.exists(fil)) download.file(URL, fil)

fil