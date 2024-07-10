# UMI-POCHI

Data processing scripts for UMI-POCHI.

## Extract eDNA data as CSV from JSON database.

UMI-POCHI provides the function to get the eDNA data as CSV.
However, the function to acquire data from multiple survey points has not yet been implemented.
Here you can find sample code for obtaining data from multiple locations from JSON.

1. Preparing a sample_list.csv
- First, create a sample_list.csv.
  Information of columns Project, Location, year, month are easily obtained from the application.
- The sample column is the sample name and can be set freely, but please make sure there are no overlaps.
- Note that if there are multiple samples in the same month at the same point, you will need to add a day column.
  It should work if you enable the comment out for the day in the script.

2. Run the script
- If it is successful, two data will be added to the output directory.
  - The df.csv is the table of read counts in the form of species x defined sample name.
  - The sample_info.csv is the data with the latitude, longitude, and other information added to sample_list.csv.
