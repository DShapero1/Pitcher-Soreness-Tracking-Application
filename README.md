# Pitcher-Soreness-Tracking-Application
A R Shiny application was built in conjunction with West Virginia University Baseball athletic trainer and strength coach to monitor athlete soreness before and after a start or relief appearance on the mound.

Using the shiny dashboard framework two widget menu items were created, one for a survey response and then the second one for the athlete to describe how they are feeling before and after an outing on the mound. 
Leveraging the googlesheets4 library in R, to create a google sheet as a remote database. After an athlete hits the save response button, the google sheet is updated. This allows for easy access for the athletic trainer and strength coach to monitor the information daily.
