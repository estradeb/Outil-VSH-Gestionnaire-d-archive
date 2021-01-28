#!/bin/bash

# [VSH][-OPTION][NOM-SERVEUR][PORT][NOM_ARCHIVE]



function CheckPort() {
#verifie si le port est correct
port=$1

	if [[ $port =~ ^[0-9]+$ ]] && [[ $port -ge 1 && $port -le 47823 ]]; then 
	#verifie si le port est bien un nombre inférieur à 47823
			echo "1"
		else
			echo "0"
	fi
}

function IsAnArchive() {
    Vtest=`head -n 1 $1 | egrep '[0-9]+:[0-9]+' `
        if [[ -n $Vtest ]]; then
                        echo "1"
        else
                        echo "0" 
        fi
}

function BasePath() #cette fonction renvoie le chemin de base de l'archive 
        {
                bp=`grep -m1 "^directory " $archive | cut -d' ' -f2`
                echo $bp
        }



function GetHeader() {
    ligne=$(cat $1 | grep '^[0-9]*:[0-9]*') 
    ligneHeader=$(echo $ligne | cut -d ':' -f1)
    ligneBody=$(echo $ligne | cut -d ':' -f2)
    ligneBody=$(($ligneBody-1))

    #cat $1 | head -n ${ligneBody} | tail -n ${ligneHeader}
    cat $1 | sed -n  "${ligneHeader},${ligneBody}p"
}

function GetLNHeader() {
    ligne=$(GetLigneNumber $1)
    ligneHeader=$(echo $ligne | cut -d ':' -f1)
    echo $ligneHeader
}

function GetBody() {
    ligne=$(cat $1 | grep '^[0-9]*:[0-9]*') 
    ligneHeader=$(echo $ligne | cut -d ':' -f1)
    ligneBody=$(echo $ligne | cut -d ':' -f2)

    awk -v n=$ligneBody 'NR>=n' $1
}

function GetLigneNumber() {
    ligne=$(cat $1 | grep '^[0-9]*:[0-9]*')
    #exemple : 3:25

    echo $ligne
}

function GetLNBody() {
    ligne=$(GetLigneNumber $1)
    ligneBody=$(echo $ligne | cut -d ':' -f2)
    #exemple : 25

    echo $ligneBody
}

function GetFileSize() {
	#prend une ligne en argument 1
	#exemple : toto2 -rw-r--r-- 249 4 10

	echo $1 | grep -o -E '[0-9]+ [0-9]+ [0-9]+' | cut -d' ' -f1
}


function GetFileContent() {
#prend une archive en argument 1
#prend une ligne en argument 2
#exemple : toto2 -rw-r--r-- 249 4 10

fichier=$2


    fileligne=$(echo $fichier | grep -E -o '[0-9]* [0-9]*$')
    #exemple 4:10
    ligneBody=$(GetLNBody $1)

    
    start=$(echo $fileligne | cut -d ' ' -f1)
    end=$(echo $fileligne | cut -d ' ' -f2)
    #exemple : start=4 et end=10

    start=$(($start+$ligneBody))
    end=$(($end+$start))
    

    if [[ $(GetFileSize "$fichier") -ne 0 ]]; then
    	cat $1 | sed -n  "${start},${end}p"
    	#GetBody $1 | sed -n  "${start},${end}p"
    fi
}

function IsAFolder() { 
#prend une ligne $1
#exemple 'A drwxr-xr-x 4096'
	Vtest=$(echo $1 | cut -d' ' -f2 | grep -o 'd')
	if [[ -n $Vtest ]]; then
		echo 1
	fi
}


function GetAccessPermission() {
#prend une ligne $1
#exemple : 'A drwxr-xr-x 4096'
	string=$(echo $1 | cut -d' ' -f2)

	#CAS USER
		
		troislettre=$(echo $string | cut -c2-4)
				testr=`echo $troislettre | grep -o 'r' `
				testw=`echo $troislettre | grep -o 'w' `
				testx=`echo $troislettre | grep -o 'x' `
		

		USER=0

		if [[ -n $testr ]]; then
			USER=$(($USER+4))
		fi

		if [[ -n $testw ]]; then
			USER=$(($USER+2))
		fi

		if [[ -n $testx ]]; then
			USER=$(($USER+1))
		fi


	#CAS GROUP

		troislettre=$(echo $string | cut -c5-7)
				testr=`echo $troislettre | grep -o 'r' `
				testw=`echo $troislettre | grep -o 'w' `
				testx=`echo $troislettre | grep -o 'x' `
		
		GROUP=0

		if [[ -n $testr ]]; then
			GROUP=$(($GROUP+4))
		fi

		if [[ -n $testw ]]; then
			GROUP=$(($GROUP+2))
		fi

		if [[ -n $testx ]]; then
			GROUP=$(($GROUP+1))
		fi


	#CAS GROUP

		troislettre=$(echo $string | cut -c8-10)
				testr=`echo $troislettre | grep -o 'r' `
				testw=`echo $troislettre | grep -o 'w' `
				testx=`echo $troislettre | grep -o 'x' `
		
		OTHER=0

		if [[ -n $testr ]]; then
			OTHER=$(($OTHER+4))
		fi

		if [[ -n $testw ]]; then
			OTHER=$(($OTHER+2))
		fi

		if [[ -n $testx ]]; then
			OTHER=$(($OTHER+1))
		fi

		echo $USER$GROUP$OTHER
	}

function GetFileName() {
#prend une ligne $1
#exemple : 'A drwxr-xr-x 4096'
	echo $1 | cut -d' ' -f1

	}

function GetEchelon() {
#prend archive file en $1
#numéro de l'echelon en $2
#GetEchelon ARCHIVE 1

	GetHeader $1 | tr '\n' '#' | cut -d'@' -f$2 | tr '#' '\n'
}


function makeFiles(){
IFS=
GetHeader $1 | grep -v 'directory' | grep -v '@' > .prep.txt

	while IFS= read -r ligne; do
		namefile=$(GetFileName $ligne)
		access=$(GetAccessPermission $ligne)


		if [[ -n $(IsAFolder $ligne) ]]; then
			mkdir $namefile
		else
			GetFileContent $1 $ligne > $namefile
		fi

		chmod $access $namefile

	done < ".prep.txt"
rm ".prep.txt"
}


function arrangeFiles() {
#$1 Archive
iteration=$(GetHeader archive_1 | egrep '^directory' | wc -l)

for (( i = 1; i < $iteration; i++ )); do

	GetEchelon $1 $i | sed '/^\s*$/d'> .temp.txt
	PathDossier=$( cat .temp.txt | sed '1q;d' | cut -d' ' -f2 | sed 's/Exemple\/Test\///g' )
	while IFS= read -r ligne; do
		mv -f $(GetFileName $ligne) $PathDossier

	done < <(tail -n +2 .temp.txt)
	rm ".temp.txt"
done

}


makeFiles $1
arrangeFiles $1