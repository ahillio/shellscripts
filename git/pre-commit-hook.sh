#!/bin/sh

# Find and remove all README.txt files before commit

#!/bin/sh
# Redirect output to stderr.
exec 1>&2
# enable user input
exec < /dev/tty

if test $(find . -iname "readme.txt" | wc -l) != 0
then 
	echo ""
	echo "Found some 'readme.txt' files."
	echo "Please delete them and then commit."
	echo ""
	echo "Run the following to delete:"
	echo ""
	echo "   find . -iname 'readme.txt' -delete"
	echo ""
	exit 1;
fi


if test $(find . -iname "readme.md" | wc -l) != 0
then 
	echo ""
	echo "Found some 'readme.md' files."
	echo "Please delete them and then commit."
	echo ""
	echo "Run the following to delete:"
	echo ""
	echo "   find . -iname 'readme.md' -delete"
	echo ""
	exit 1;
fi


if test $(find . -iname "changelog.txt" | wc -l) != 0
then 
	echo ""
	echo "Found some 'changelog.txt' files."
	echo "Please delete them and then commit."
	echo ""
	echo "Run the following to delete:"
	echo ""
	echo "   find . -iname 'changelog.txt' -delete"
	echo ""
	exit 1;
fi


if test $(find . -iname "changelog.md" | wc -l) != 0
then 
	echo ""
	echo "Found some 'changelog.md' files."
	echo "Please delete them and then commit."
	echo ""
	echo "Run the following to delete:"
	echo ""
	echo "   find . -iname 'changelog.md' -delete"
	echo ""
	exit 1;
fi

