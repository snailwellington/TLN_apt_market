# Tallinn housing market from 2003 III to 2018 III

A look into how different districts and regions ("asum" in estonian) of Tallinn recovered from 2008/09 recession. Additional look on how different areas of Tallinn are priced and how has the prices changed.


Next things:
- Make an inital gif to see how transaction per region area has changed - done
- Re-organise the files to know which files are needed to be ran to get all the necessary data objects []
- Get price information for regions. Currently regions are missing price data if there was less than 5 transactions. Plan is to use district price data for that.
- Calculate price indexes and changes for regions and districts
- Try to find correlations as shown in the example project

# Some results

![total_count_gif](https://github.com/snailwellington/price_stat/blob/master/output/total_count.gif)

# Sources:
- Price statistics - http://www.maaamet.ee/kinnisvara/htraru/FilterUI.aspx (27/07/2018)
- Map info - https://geoportaal.maaamet.ee/est/Andmed-ja-kaardid/Haldus-ja-asustusjaotus-p119.html (27/07/2018)
			https://www.tallinn.ee/est/ehitus/Tallinna-linnaosade-ja-asumite-piirid (27/07/2018)
- Asum and District info - https://et.wikipedia.org/wiki/Tallinna_asumid (30/07/2018)
