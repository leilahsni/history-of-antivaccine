for file in 'ls ./PREP_CORPUS' ; do echo $file;
echo "<file="$file">" >> contatenate.txt;
cat ./PREP-CORPUS/$file >>  contatenate.txt ;
echo "</file>" >> contatenate.txt ;
done;