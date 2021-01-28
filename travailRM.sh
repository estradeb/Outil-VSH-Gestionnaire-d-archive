#!/bin/bash

	FileisArchive()
        	{
                	Vtest=`head -n 1 $1 | egrep '[0-9]+:[0-9]+' `
                	if [[ -n $Vtest ]]; then
                	        echo "1"
                	else    
                	        echo "0" 
                	fi
        	}

function GetHeader() {
    ligne=$(cat $1 | grep '^[0-9]*:[0-9]*') 
    ligneHeader=$(echo $ligne | cut -d ':' -f1)
    ligneBody=$(echo $ligne | cut -d ':' -f2)
    ligneBody=$(($ligneBody-1))

    #cat $1 | head -n ${ligneBody} | tail -n ${ligneHeader}
    cat $1 | sed -n  "${ligneHeader},${ligneBody}p"
}


	list() 
		{
			for fichier in `ls`; do  
                	        if [[ `FileisArchive $fichier` == "1" ]]; then  
                	                echo $fichier 
                        	fi
                	done
		}


	BasePath() #cette fonction renvoie le chemin de base de l'archive 
        	{
                	bp=`grep -m1 "^directory " $1 | cut -d' ' -f2`
                	echo $bp | sed -e 's/\/$//'
        	}

 	getmsg() 
		{
 			while read line; do
        		set -- $line 
        #echo "$1"      
        #echo "$2"
        #echo "$3"
	#echo "$4"
			export BASEPATH=$(BasePath "$1") 
	#echo $BASEPATH
				 case $2 in
        				"ls")	
						if [[ -z $4 ]]; then 
							fls=$(vsh_ls $3 $1)
							echo $fls
						elif [[ $4 == '-l' ]]; then 
							vsh_ls $3 $1 $4
						else 
							echo "option inconnue" 
						fi 
                				;;
        				"cd")	 
                				path=`echo $3 | cut -d'/' -f1`
                				TestPath=`grep -e "^directory $BASEPATH$4$path $" $1`

       				                 if [[ $3 == ".." ]]; then
      				                        echo $4 | sed -e 's/[^\/]*\/$//'
                        			elif [[ $3 == "/" ]]; then
                        			        echo "/"
                       				 elif [[ -n $TestPath ]]; then
							if [[ $3 =~ .*\/$ ]]; then
                                				echo $4$3
							else 
								echo $4$3'/'
							fi
                        			else
                        			        echo -e "ce dossier n'existe pas"
                       				fi
                				;;
        				"cat")
						Test=$(vsh_ls $4 $1 | grep -e "$3") 
						if [[ $(IsAFolder $1 $3) == '1' ]]; then 
							echo " tu essaies de cat un dossier xD"
						elif [[ -n $Test  ]]; then 
							GetFileContent $1 $3
						else 
							echo "ce fichier n'existe pas :p"
						fi
        				        ;;
       					 "rm")
						Test=$(vsh_ls $4 $1 | grep -e "$3") 
						if [[ $(IsAFolder $1 $3) == '1' ]]; then
                                                        echo " tu essaies de cat un dossier xD"
						elif [[ -n $Test  ]]; then 
							vsh_rm $1 $3		
						else 
							echo "ce fichier n'existe pas :p"
						fi
        				        ;;
        				       

       					 "list")
                				list
                				;;
					
					 "extract") 
						cat $1 	
				esac

			done
	}

	vsh_rm() {
		fichier=$(cat $1 | grep -e "$2")
   		fileligne=$(echo $fichier | grep -o '[0-9]* [0-9]*$')
    #exemple 4 10
		ligneInDir=$(cat $1 | grep -n "$2" | grep -o '^[0-9]*')
		echo "$ligneInDir" 
    		ligneBody=$(GetLNBody $1)

  		start=$(echo $fileligne | cut -d ' ' -f1)
	
    		end=$(echo $fileligne | cut -d ' ' -f2)

    		start=$(($start+$ligneBody-1))	
		echo $start 
    		end=$(($end+$start-1))
		echo $end
        	sed "${start},${end}d" $1 | sed "$ligneInDir d" >> te 
		mv te $1
	}


	function rmdirectory() {
		#archive en argument 1
		#nom du dossier a supprimer argument 2
		header=$(GetHeader $1)
		IFS=
		start=$(echo header | grep -e $2)
		#| cut -d':' -f1 
		echo $start
	}
	rmdirectory archive_1 A1

	CheckPort() { #verifie si le port est correct
		port=$1
		if [[ $port =~ ^[0-9]+$ ]] && [[ $port -ge 1 && $port -le 47823 ]]; then #verifie si le port est bien un nombre inférieur à 47823
			echo "1"
		else
			echo "0"
		fi
	}


	vsh_ls() { #$1 la position dans l'archive 
		   #$2 l'archive 
		   #$3 l'option 
		start=$(($(getline $1 $2)+1))
		end=$(($(cat $2 | tail -n +$start | grep -n -m1 '^@' | grep -o '^[0-9]*')+$start-2))	
		if [[ -n $3 ]]; then
			cat $2 | sed -n "$start, $end p"
		else
			oldIFS=$IFS
			IFS='\n'
		  	for ligne in $(cat $2 | sed -n "$start, $end p");do 
				#te=$(echo $ligne | cut -d' ' -f1)
				#te=$(IsAFolder $2 "A")
				#if [[ $(IsAFolder $2 $te) == '1' ]]; then 
				#	echo $te'/'
				#elif [[ $(IsExec $2 $te) == '1' ]]; then
				#	echo $te'*' 
				#else  
				echo $ligne | cut -d' ' -f1
				#fi 
			done
		fi	
	 }


	getline() { #$1 notre position dans l'archive 
		if [[ $1 == '/' ]]; then 
			path=$(grep -n "^directory $BASEPATH$1 $" $2 )
			echo $path | grep -o '^[0-9]*'
		elif [[ $1 =~ ^\/.* ]]; then 
			pat=$(echo $1 | sed -e 's/\/$//')
			path=$(grep -n "^directory $BASEPATH$pat $" $2 )
                	echo $path | grep -o '^[0-9]*'
		fi
	}




	GetLNHeader() {
		ligne=$(GetLigneNumber $1)
		ligneHeader=$(echo $ligne | cut -d ':' -f1)
		echo $ligneHeader
	}


	GetBody() {
		ligne=$(cat $1 | grep '^[0-9]*:[0-9]*') 
		ligneHeader=$(echo $ligne | cut -d ':' -f1)
		ligneBody=$(echo $ligne | cut -d ':' -f2)

		awk -v n=$ligneBody 'NR>=n' $1
	}


	GetLigneNumber() { 
 		ligne=$(cat $1 | grep '^[0-9]*:[0-9]*') #exemple : 3:25
		echo $ligne
	}

	GetLNBody() {
		ligne=$(GetLigneNumber $1)
		ligneBody=$(echo $ligne | cut -d ':' -f2) #exemple : 25
		echo $ligneBody
	}

	GetFileSize() {
		#prend une ligne en argument 1
		#exemple : toto2 -rw-r--r-- 249 4 10

		echo $1 | grep -o -E '[0-9]+ [0-9]+ [0-9]+' | cut -d' ' -f1
	}



	IsAFolder() { 
		#prend une ligne $1
		#exemple 'A drwxr-xr-x 4096'
		fichier=$(cat $1 | grep -e "$2")
		Vtest=$(echo $fichier | cut -d' ' -f2 | grep -o 'd')
		if [[ -n $Vtest ]]; then
			echo 1
		else 
			echo 0
		fi
 	}

	IsExec() { 
		#prend une ligne $1
		#exemple 'A drwxr-xr-x 4096'
		fichier=$(cat $1 | grep -e "$2")
		Vtest=$(echo $fichier | cut -d' ' -f2 | grep -o 'x')
		if [[ -n $Vtest ]]; then
			echo 1
		else 
			echo 0
		fi
 	}

	GetFileContent() {
		#prend une archive en argument 1
		#prend le nom du dossier a afficher en argument 
		#exemple : toto2 -rw-r--r-- 249 4 10

		fichier=$(cat $1 | grep -e "$2")
		fileligne=$(echo $fichier | grep -o '[0-9]* [0-9]*$') #exemple 4 10	
		ligneBody=$(GetLNBody $1)
     		start=$(echo $fileligne | cut -d ' ' -f1)

		end=$(echo $fileligne | cut -d ' ' -f2)
	
		#exemple : start=4 et end=10

		start=$(($start+$ligneBody-1))

		end=$(($end+$start-1))
    

		#  if [[ $(GetFileSize "$fichier") -ne 0 ]]; then
    	        cat $1 | sed -n  "${start},${end}p"
	    	#GetBody $1 | sed -n  "${start},${end}p"
		 # fi
	}