#!/usr/bin/bash
#-------------------------------------------------------
# pour lancer ce script:
# bash premierscript.sh <dossier URL> <dossier TABLEAUX>
#-------------------------------------------------------
# remove the table file
rm -f "$2/tableau.html" ;
rm -f "./CONTEXTES/contexte-"$cptTableau-$compteur".txt" ;
rm -f "./PAGES-ASPIREES-"$cptTableau-$compteur".txt" ;
#-------------------------------------------------------
# stocker les arguments dans des variables
DOSSIER_URLS=$1 ;
DOSSIER_TABLEAUX=$2 ;
motif=$3;

if [[ $# -eq 3 ]] 
    then 
        echo "Le nombre d'arguments est correct."
	else 
    	echo "Le nombre d'arguments est incorrect. Il en faut 3."
    	exit
fi

#-------------------------------------------------------
# en-tête du fichier html + CSS
echo "<html>
	<head>
		<meta charset=\"utf-8\"/>
		<title>Antivax</title>
		<style>

		html, body, div, span, applet, object, iframe,
		h1, h2, h3, h4, h5, h6, p, blockquote, pre,
		a, abbr, acronym, address, big, cite, code,
		del, dfn, em, img, ins, kbd, q, s, samp,
		small, strike, strong, sub, sup, tt, var,
		b, u, i, center,
		dl, dt, dd, ol, ul, li,
		fieldset, form, label, legend,
		table, caption, tbody, tfoot, thead, tr, th, td,
		article, aside, canvas, details, embed, 
		figure, figcaption, footer, header, hgroup, 
		menu, nav, output, ruby, section, summary,
		time, mark, audio, video {
			margin: 0;
			padding: 0;
			border: 0;
			font-size: 100%;
			font: inherit;
			vertical-align: baseline;
		}

		a {
			color:#325D5D;
			text-decoration:none;
		}

		a:hover {
			color:#4D938E;
		}

		.line:hover {
		background-color:#D7EAEA;
		}

		table {
			align=\"center\";
			border: none;
    		border-collapse: separate;
			background-color:#F2F8F8;
			color:#325D5D;
			table-layout: fixed;
			width:100%;
			word-wrap:break-word;
		}

		td { 
    	padding: 10px;
		text-align:center;
		}

		.header {
			background-color:#A1CECE;
			text-align:center;
			color:#386B6B;
		}

		h1 {
			text-align:center;
			font-size:30px;
			color:#A1CECE;
			padding-top:50px;
			background-color:#F2F8F8;
		}

		h2 {
			text-align:center;
			color:#A1CECE;
			padding-bottom:50px;
			background-color:#F2F8F8;
		}

		h3 {
			background-color:#F2F8F8;
			text-align:center;
			padding-bottom:10px;
			border-top: thin solid #A1CECE;
			color:#325D5D;
			padding:5px;
		}

		</style>
	</head>
	<body>
	<h1>Antivax</h1>
	<h2>FR, EN, KR, MS</h2>" > $DOSSIER_TABLEAUX/tableau.html ;
#-------------------------------------------------------
cptTableau=0;

# pour chaque élément contenu dans DOSSIER_URL
for fichier in $(ls $DOSSIER_URLS); do
	echo "Fichier lu : $fichier" ;
	# on compte les tableaux
	cptTableau=$(($cptTableau + 1)) ;
	# on va aussi compter les URLs de chaque tableau
	compteur=0 ;
	# Pour chaque fichier => 1 tableau HTML
	# Début de tableau
	echo "<h3>Tableau n°${cptTableau}</h3>
	<h3>Fichier: ${fichier}</h3>
	<h3>Motif: ${motif}</h3>
	<table cellspacing=\"0\" cellpadding=\"0\">" >> $DOSSIER_TABLEAUX/tableau.html ;
	echo "<tr class=\"header\"><td>Num.</td><td>Code HTTP</td><td>Encodage</td><td>URL</td><td>Index</td><td>Bigramme</td><td>Page aspirée</td><td>DUMP-TEXT</td><td>Contexte TXT</td><td>Contexte HTML<td>Nombre Motif</td></tr>" >> $DOSSIER_TABLEAUX/tableau.html ;
    # lire chaque fichier du dossier
	while read line; do
		compteur=$(($compteur + 1)) ;
		# je peux travailler avec line (l'url)
		# 1. Une variable pour vérifier si la connexion vers l'URL est OK
		codeHTTP=$(curl $line -# -w '%{http_code}\n' -o ./PAGES-ASPIREES/"$cptTableau-$compteur".html)
		# 2. une variable pour essayer de repérer l'encodage via CURL
		encodage=$(curl -L -I $line | egrep "charset" -m 1 | cut -d "=" -f2 | tr -d '\r' | tr -d '\n' | tr '[:lower:]' '[:upper:]')
		
		if [[ $codeHTTP == 200 ]]
			then 

				if [[ $encodage == "UTF-8" ]]
				then
					echo "L'encodage reconnu est ${encodage}."
					LANG="kr.KR.UTF-8"
					lynx -dump -nolist -assume_charset="UTF-8" -display_charset="UTF-8" ./PAGES-ASPIREES/"$cptTableau-$compteur".html > ./DUMP-TEXT/"$cptTableau-$compteur".txt;
					#création de l'index
					
					if [[ $cptTableau == 2 ]]
					then
						iconv -f UTF-8 -t UTF-8//IGNORE ./DUMP-TEXT/"$cptTableau-$compteur".txt > ./DUMP-TEXT/"$cptTableau-$compteur"-UTF-8.txt
				
						python3 ./PROGRAMMES/segmentizer.py ./DUMP-TEXT/"$cptTableau-$compteur"-UTF-8.txt ./DUMP-TEXT/seg-"$cptTableau-$compteur".txt 
						cat ./DUMP-TEXT/seg-"$cptTableau-$compteur".txt | egrep -o "(\w|[가-힣])+" | sort | uniq -c | sort -nr > ./DUMP-TEXT/index-"$cptTableau-$compteur".txt;
						#création des bigrammes
						egrep -o "(\w|[가-힣])+" ./DUMP-TEXT/seg-"$cptTableau-$compteur".txt > bigramme1.txt;
					else
						egrep -o "(\w+)" ./DUMP-TEXT/"$cptTableau-$compteur".txt > bigramme1.txt;
					fi

					tail -n +2 bigramme1.txt > bigramme2.txt;
					paste bigramme1.txt bigramme2.txt > bigramme3.txt;		
					cat bigramme3.txt | sort | uniq -c | sort -nr > ./BIGRAMMES/bigramme-"$cptTableau-$compteur".txt
																	
			
				#l'encodage n'est pas trouvé
				elif [[ ! $encodage ]]; then
					echo "L'encodage n'est pas reconnu."
					encodage=$(curl -L -I $line | egrep "charset" -m 1 | cut -d "=" -f2 | tr -d ‘\r’ | tr '[:lower:]' '[:upper:]')

					if [[ $encodage == "UTF-8" ]]; then
							echo "L'encodage reconnu est UTF-8."
							LANG="kr.KR.UTF-8"
							lynx -dump -nolist -assume_charset="UTF-8" -display_charset="UTF-8" ./PAGES-ASPIREES/"$cptTableau-$compteur".html > ./DUMP-TEXT/"$cptTableau-$compteur".txt;
							
							if [[ $cptTableau == 2 ]]
							then
								iconv -f UTF-8 -t UTF-8//IGNORE ./DUMP-TEXT/"$cptTableau-$compteur".txt > ./DUMP-TEXT/"$cptTableau-$compteur"-UTF-8.txt
				
								python3 ./PROGRAMMES/segmentizer.py ./DUMP-TEXT/"$cptTableau-$compteur"-UTF-8.txt ./DUMP-TEXT/seg-"$cptTableau-$compteur".txt 
								cat ./DUMP-TEXT/seg-"$cptTableau-$compteur".txt | egrep -o "(\w|[가-힣])+" | sort | uniq -c | sort -nr > ./DUMP-TEXT/index-"$cptTableau-$compteur".txt;
								#création des bigrammes
								egrep -o "(\w|[가-힣])+" ./DUMP-TEXT/seg-"$cptTableau-$compteur".txt > bigramme1.txt;
							else
								egrep -o "(\w+)" ./DUMP-TEXT/"$cptTableau-$compteur".txt > bigramme1.txt;
							fi
							
							tail -n +2 bigramme1.txt > bigramme2.txt;
							paste bigramme1.txt bigramme2.txt > bigramme3.txt;		
							cat bigramme3.txt | sort | uniq -c | sort -nr > ./BIGRAMMES/bigramme-"$cptTableau-$compteur".txt

				#l'encodage est bien en UTF-8, on continue
					elif [[ ! $encodage ]]; then
						echo "L'encodage n'est pas reconnu, on suppose qu'il est en UTF-8."
						LANG="kr.KR.UTF-8"
						lynx -dump -nolist -assume_charset="UTF-8" -display_charset="UTF-8" ./PAGES-ASPIREES/"$cptTableau-$compteur".html > ./DUMP-TEXT/"$cptTableau-$compteur".txt;
						# pour qu'il s'affiche bien en UTF-8 dans notre tableau
						encodage="UTF-8"

							if [[ $cptTableau == 2 ]]
							then
								iconv -f UTF-8 -t UTF-8//IGNORE ./DUMP-TEXT/"$cptTableau-$compteur".txt > ./DUMP-TEXT/"$cptTableau-$compteur"-UTF-8.txt
				
								python3 ./PROGRAMMES/segmentizer.py ./DUMP-TEXT/"$cptTableau-$compteur"-UTF-8.txt ./DUMP-TEXT/seg-"$cptTableau-$compteur".txt 
								cat ./DUMP-TEXT/seg-"$cptTableau-$compteur".txt | egrep -o "(\w|[가-힣])+" | sort | uniq -c | sort -nr > ./DUMP-TEXT/index-"$cptTableau-$compteur".txt;
								#création des bigrammes
								egrep -o "(\w|[가-힣])+" ./DUMP-TEXT/seg-"$cptTableau-$compteur".txt > bigramme1.txt;
							else
								egrep -o "(\w+)" ./DUMP-TEXT/"$cptTableau-$compteur".txt > bigramme1.txt;
							fi

							tail -n +2 bigramme1.txt > bigramme2.txt;
							paste bigramme1.txt bigramme2.txt > bigramme3.txt;		
							cat bigramme3.txt | sort | uniq -c | sort -nr > ./BIGRAMMES/bigramme-"$cptTableau-$compteur".txt

					else
						echo "L'encodage est en ${encodage}: conversion en cours..."
						iconv -f $encodage -t UTF-8 ./PAGES-ASPIREES/$cptTableau-$compteur.html > ./PAGES-ASPIREES/$cptTableau-$compteur-UTF8.html
						echo "L'encodage après conversion est ${encodage}."
						LANG="kr.KR.UTF-8"
						lynx -dump -nolist -assume_charset="UTF-8" -display_charset="UTF-8" ./PAGES-ASPIREES/$cptTableau-$compteur-UTF8.html > ./DUMP-TEXT/"$cptTableau-$compteur".txt
						encodage="${encodage} (converti)"

							if [[ $cptTableau == 2 ]]
							then
								iconv -f UTF-8 -t UTF-8//IGNORE ./DUMP-TEXT/"$cptTableau-$compteur".txt > ./DUMP-TEXT/"$cptTableau-$compteur"-UTF-8.txt
				
								python3 ./PROGRAMMES/segmentizer.py ./DUMP-TEXT/"$cptTableau-$compteur"-UTF-8.txt ./DUMP-TEXT/seg-"$cptTableau-$compteur".txt 
								cat ./DUMP-TEXT/seg-"$cptTableau-$compteur".txt | egrep -o "(\w|[가-힣])+" | sort | uniq -c | sort -nr > ./DUMP-TEXT/index-"$cptTableau-$compteur".txt;
								#création des bigrammes
								egrep -o "(\w|[가-힣])+" ./DUMP-TEXT/seg-"$cptTableau-$compteur".txt > bigramme1.txt;
							else
								egrep -o "(\w+)" ./DUMP-TEXT/"$cptTableau-$compteur".txt > bigramme1.txt;
							fi

							tail -n +2 bigramme1.txt > bigramme2.txt;
							paste bigramme1.txt bigramme2.txt > bigramme3.txt;		
							cat bigramme3.txt | sort | uniq -c | sort -nr > ./BIGRAMMES/bigramme-"$cptTableau-$compteur".txt

					fi
				else

					echo "L'encodage est en ${encodage}: conversion en cours..."
					iconv -f $encodage -t UTF-8 ./PAGES-ASPIREES/$cptTableau-$compteur.html > ./PAGES-ASPIREES/$cptTableau-$compteur-UTF8.html
					echo "L'encodage après conversion est ${encodage}."
					LANG="kr.KR.UTF-8"
					lynx -dump -nolist -assume_charset="UTF-8" -display_charset="UTF-8" ./PAGES-ASPIREES/$cptTableau-$compteur-UTF8.html > ./DUMP-TEXT/"$cptTableau-$compteur".txt
					encodage="${encodage} (converti)"

							if [[ $cptTableau == 2 ]]
							then
								iconv -f UTF-8 -t UTF-8//IGNORE ./DUMP-TEXT/"$cptTableau-$compteur".txt > ./DUMP-TEXT/"$cptTableau-$compteur"-UTF-8.txt
				
								python3 ./PROGRAMMES/segmentizer.py ./DUMP-TEXT/"$cptTableau-$compteur"-UTF-8.txt ./DUMP-TEXT/seg-"$cptTableau-$compteur".txt 
								cat ./DUMP-TEXT/seg-"$cptTableau-$compteur".txt | egrep -o "(\w|[가-힣])+" | sort | uniq -c | sort -nr > ./DUMP-TEXT/index-"$cptTableau-$compteur".txt;
								#création des bigrammes
								egrep -o "(\w|[가-힣])+" ./DUMP-TEXT/seg-"$cptTableau-$compteur".txt > bigramme1.txt;
							else
								egrep -o "(\w+)" ./DUMP-TEXT/"$cptTableau-$compteur".txt > bigramme1.txt;
							fi

							tail -n +2 bigramme1.txt > bigramme2.txt;
							paste bigramme1.txt bigramme2.txt > bigramme3.txt;		
							cat bigramme3.txt | sort | uniq -c | sort -nr > ./BIGRAMMES/bigramme-"$cptTableau-$compteur".txt

				fi
		

			#récupération du contexte HTML
			perl ./PROGRAMMES/minigrep/minigrepmultilingue.pl "UTF-8" ./DUMP-TEXT/$cptTableau-$compteur.txt ./PROGRAMMES/minigrep/motif-regexp.txt ./CONTEXTES/$cptTableau-$compteur.html ;

			#récupération du contexte TXT
			cat ./DUMP-TEXT/"$cptTableau-$compteur".txt | egrep -i -C3 "$motif" > ./CONTEXTES/contexte-"$cptTableau-$compteur".txt;
			nbmotif=$(egrep -coi "$motif" ./DUMP-TEXT/$cptTableau-$compteur.txt);

				# construction des lignes du tableau pour les fichiers de code HTTP 200
			echo "<tr class=\"line\"><td>$compteur</td><td>$codeHTTP</td><td>$encodage</td><td><a href=\"$line\">$line</a></td><td><a href=\"../DUMP-TEXT/index-$cptTableau-$compteur.txt\">Index</a></td><td><a href=\"../BIGRAMMES/bigramme-$cptTableau-$compteur.txt\">Bigramme</td></a><td><a href=\"../PAGES-ASPIREES/$cptTableau-$compteur.html\">$cptTableau-$compteur</a></td><td><a href=\"../DUMP-TEXT/$cptTableau-$compteur-UTF-8.txt\">$cptTableau-$compteur</a></td><td><a href=\"../CONTEXTES/contexte-$cptTableau-$compteur.txt\">Contexte</a><td><a href=\"../CONTEXTES/$cptTableau-$compteur.html\">Contexte</a></td><td>$nbmotif</td></tr>" >> $DOSSIER_TABLEAUX/tableau.html ;
			else
			    # construction des lignes du tableau pour les fichiers de code autre que HTTP 200
			echo "<tr class=\"line\"><td>$compteur</td><td>$codeHTTP</td><td>$encodage</td><td><a href=\"$line\">$line</td><td>–</td><td>–</td><td>–<td>–</td><td>–</td><td>–</td><td>–</td></tr>" >> $DOSSIER_TABLEAUX/tableau.html ;
			
		fi

		#echo "<fichier="\"$compteur\"">$(<./DUMP-TEXT/$cptTableau-$compteur-UTF-8.txt)</fichier>" >> concat-tableau-$cptTableau.txt
	
	done < $DOSSIER_URLS/$fichier ;

# Fin du tableau (et de la lecture du fichier)
echo "</table><hr/>" >> $DOSSIER_TABLEAUX/tableau.html ;
done;
echo "</body>
</html>" >> $DOSSIER_TABLEAUX/tableau.html ;
exit;