#! /bin/bash
# process csv of politician statements for LGK

# I think the following two lines should be run on politicians.csv
sed -i.bak 's/Requested,,/Requested,"Declined to comment.",/g' politician-districts__copypaste.csv
sed -i 's/Declined,,/Declined,"Declined to comment.",/g' politician-districts__copypaste.csv

# temporarily put this here:
# change to lowercase
sed -i 's/\(.*\)/\L\1/' name-on-ballet.csv
# captialize
sed -i 's/[^ "]*/\u&/g' name-on-ballet.csv

# We need to change some county names to match the format JK sent
# :%s/Grand Isle/Grand-Isle-Chittenden/g
# :%s/Grand Isle-Chittenden/Grand-Isle-Chittenden/g

# these are too aggressive, they mess with candidate names,
# so we'll copy/paste the columns into a separate file and operate on that instead.
sed -i 's/ADD/Addison/g' politician-districts__copypaste.csv
sed -i 's/BEN/Bennington/g' politician-districts__copypaste.csv
sed -i 's/CAL/Caledonia/g' politician-districts__copypaste.csv
sed -i 's/CHI/Chittenden/g' politician-districts__copypaste.csv
sed -i 's/ESX/Essex/g' politician-districts__copypaste.csv
sed -i 's/FRA/Franklin/g' politician-districts__copypaste.csv
sed -i 's/GI/Grand Isle/g' politician-districts__copypaste.csv
sed -i 's/LAM/Lamoille/g' politician-districts__copypaste.csv
sed -i 's/ORA/Orange/g' politician-districts__copypaste.csv
sed -i 's/ORL/Orleans/g' politician-districts__copypaste.csv
sed -i 's/RUT/Rutland/g' politician-districts__copypaste.csv
sed -i 's/WAS/Washington/g' politician-districts__copypaste.csv
sed -i 's/WDH/Windham/g' politician-districts__copypaste.csv
sed -i 's/WDR/Windsor/g' politician-districts__copypaste.csv

