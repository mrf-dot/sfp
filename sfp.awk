#!/bin/awk -f

BEGIN {
	# Check that there is right # of args
	if (ARGC == 4 && ARGV[1] == "h") {
		dir = ARGV[2]
		fp = ARGV[3]
		human=1
	} else if (ARGC == 3) {
		dir = ARGV[1]
		fp = ARGV[2]
	} else {
		print "Usage: sfp [h] <directory> <file-pattern>" > "/dev/stderr"
		print "Example: sfp /usr/local/bin '*.sh'" > "/dev/stderr"
		exit 1
	}

	# Escape single quotes to prevent shell injection
	gsub(/'/, "'\\''", dir)
	gsub(/'/, "'\\''", fp)

	# Check that user provided a valid directory
	cmd=sprintf("[ -d '%s' ]", dir)
	if (system(cmd)) {
		print "Error: Directory '" dir "' does not exist" > "/dev/stderr"
		exit 1
	}

	# Find all files that match the given pattern
	cmd=sprintf("find '%s' -name '%s' -type f -exec stat -c %%s '{}' + 2>/dev/null", dir, fp)

	# Iterate over the command
	while ((cmd | getline line ) > 0) {
		sum += line
	}

	# Cleanup
	close(cmd)

	# Print the size in a human readable format
	if (human) {
		print human_filesize(sum)
	} else {
		print sum
	}
	exit 0
}

function human_filesize(size,    sizes, unit) {
	split("B KB MB GB TB PB", sizes)
	while (size >= 1000 && unit < length(sizes)) {
		size /= 1000
		unit++
	}
	return sprintf("%.2f %s", size, sizes[unit+1])
}
