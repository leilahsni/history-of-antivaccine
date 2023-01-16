#!/usr/bin/env python
# -*- coding: utf-8 -*-

# permet d'utiliser les fichiers en argument dans notre script bash
import sys
# notre module pour segmenter le coréen
from konlpy.tag import Okt
import string

okt = Okt()

with open (sys.argv[1], 'r', encoding="utf-8") as file:
    file = file.read()
    # je segmente avec Okt
    segText = " ".join(okt.morphs(file))
    # j'en profite pour enlever la ponctuation
    string.punctuation = "!\"#$%&'()*+,-./:;<=>?@[\]^_`{|}~…”‘·’“ㅣ"
    text = list(filter(lambda word: word not in string.punctuation, segText))
    text = "".join(text)
    # on n'oublie pas de créer un nouveau fichier avec notre texte segmenté
    with open (sys.argv[2], 'w', encoding="utf-8") as new_file:
        new_file = new_file.write(text)