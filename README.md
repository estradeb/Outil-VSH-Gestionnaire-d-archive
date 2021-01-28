# Outil VSH - Gestionnaire d'archive
**Fonctionnel mais non testé depuis 2018.** 
Ce projet est un serveur d’archive original. Le sujet du projet se trouve dans **LO14-Projet-2018.pdf**.

* 1er mode: c'est le mode list :  `vsh  -list nom_serveur port`. Cette   commande   permet   d’afficher   la   liste   des   archives   présentes  sur  le  serveur.  nom_serveur  représente  l’adresse  du  serveur  et  port  le  numéro  du  port  sur  lequel  le  serveur  attend  une requête.   
* 2ème mode: c'est le mode browse :  `vsh   -browse  nom_serveur port  nom_archive`. Cette commande vous permet d'explorer sur le serveur l'archive nom_archive en vous faisant entrer dans un mode shell vsh. 
* 3ème mode: c'est le mode extract :   `vsh -extract nom_serveur port  nom_archive`
