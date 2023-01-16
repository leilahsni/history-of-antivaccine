#!/usr/bin/bash

################
rm ../URLS/fichiers.txt
################

page="https://search.naver.com/search.naver?query=백신+거부자&where=news&ie=utf8&sm=nws_hty"
word="백신 거부자"

# je crée une fonction qui va me permettre de crawl la première page
function crawl(){
# pour un mot dans mon argument 1 (ma page)
	for my_word in $page; do if 
# tant que ce mot est égal à mon argument 2 (mot recherché)
		my_word=$word; then
# je vais récupérer l'url de la page dans un fichier appelé fichier.txt dans mon dossier URLS
# j'utilise 'pup' qui va me permettre de selectionner une class CSS et donc de ne récupérer que
# le html qui contient les liens des titres d'articles (et non les liens des pages d'accueil)
		curl $page | pup 'div.news_area a[class="news_tit"]' > ../URLS/fichier.txt
# j'utilise les expressions régulières pour ne récupérer que les liens (et non plus toute la div)                  
		links=$(grep -Eo '(http|https):[a-zA-Z0-9./?=_%:-]*' ../URLS/fichier.txt | sort -u)
		echo $links | sed -e 's/ /\n/g' > ../URLS/fichiers.txt
    	fi
    done
}

# fonction me permettant de crawl les autres pages
function get_next_page_links(){

#je vais jusque la page 4 car je n'ai besoin que de 50 liens
#mais il pourrait aller plus loin
for idx_counter in {1..4};
do
#je remarque le pattern changeant dans le lien original
#et je change ce pattern à chaque boucle avec une variable
			next_page="https://search.naver.com/search.naver?where=news&sm=tab_pge&query=백신%20거부자&sort=0&photo=0&field=0&pd=0&ds=&de=&cluster_rank=13&mynews=0&office_type=0&office_section_code=0&news_office_checked=&nso=so:r,p:all,a:all&start=${idx_counter}1"
			curl $next_page | pup 'div.news_area a[class="news_tit"]' > ../URLS/fichier.txt; echo "page curled"
			links=$(grep -Eo '(http|https):[a-zA-Z0-9./?=_%:-]*' ../URLS/fichier.txt | sort -u)
			#j'envoie mes liens dans fichiers.txt et nettoie mon fichier avec un sed
			echo $links | sed -e 's/ /\n/g' >> ../URLS/fichiers.txt; echo "fichiers.txt updated"
done

}

#j'appelle mes fonctions
crawl $page $word
get_next_page_links $page $word

#je supprime fichier.txt car il ne contient que le HTML de la page
#qui ne me sers à rien
rm ../URLS/fichier.txt