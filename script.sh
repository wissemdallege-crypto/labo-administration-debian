# !/ bin / bash
# Boucle for ( parcourir une liste )
for user in alice bob charlie
do
echo " Traitement de l ’ utilisateur : $user "
done
# Boucle while ( compteur simple )
compteur=3
while [ $compteur -gt 0 ]
do
echo " Compte a rebours : $compteur "
((compteur --))
done
