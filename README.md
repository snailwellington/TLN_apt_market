# Tallinn housing market from 2003 III to 2018 III

A look into how apartment market in different districts and regions ("asum" in estonian) of Tallinn recovered from 2008/09 recession. Additional look on how different areas of Tallinn are priced and how has the prices changed.


Next things:
- Make an inital gif to see how transaction per region area has changed - done
- Check all the plots if they are up to date with "sf" library
- Write functions for shp plots, and use it!
- Make year facet for changes
- Re-organise the files to know which files are needed to be ran to get all the necessary data objects []
- Get price information for regions. Currently regions are missing price data if there was less than 5 transactions. Plan is to use district price data for that.
- Calculate price indexes and changes for regions and districts
- Hot spot analysis Getis-Ord Gi statistic https://www.youtube.com/watch?v=qQNOlfOYtyw
- Try to find correlations as shown in the example project

# Some results

![total_count_gif](https://github.com/snailwellington/price_stat/blob/master/output/transaction_p_ha.gif)

# Sources:
- Price statistics - http://www.maaamet.ee/kinnisvara/htraru/FilterUI.aspx (27/07/2018)
- Map info - https://geoportaal.maaamet.ee/est/Andmed-ja-kaardid/Haldus-ja-asustusjaotus-p119.html (27/07/2018)
			https://www.tallinn.ee/est/ehitus/Tallinna-linnaosade-ja-asumite-piirid (27/07/2018)
- Asum and District info - https://et.wikipedia.org/wiki/Tallinna_asumid (30/07/2018)
- Fisher Ideal Price Index example - http://mba-lectures.com/statistics/descriptive-statistics/561/fisher-ideal-price-index.html


- sf package information https://cran.r-project.org/web/packages/sf/index.html
