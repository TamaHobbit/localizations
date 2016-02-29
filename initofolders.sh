find . -type f | (while read file; do mv $file `echo $file | sed 's/\.ini/\.txt/'`; done)
ls | (while read file; do clean=`echo $file | cut -d'.' -f1`; mkdir $clean; mv $file $clean; done)