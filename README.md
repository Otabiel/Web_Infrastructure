# Labo web infrastructure

# Basset Nils & Da Rocha Carvalho Bruno



## Etape 1 : Serveur HTTP statique

### Infrasctructure

Dans le répertoire `./docker-images/apache-php-image/`

Dossier `src/` -> contient les fichiers sources du site web

Dockerfile :

```dockerfile
FROM php:7.2-apache 
COPY src/ /var/www/html/ 
```

FROM : Instruction utilisée pour spécifier le nom de l'image docker et start le processus

COPY : Instruction utilisée pour copier un fichier ou un répertoire de notre hôte vers l'image Docker. Copie l'élément dans le context d'instruction de docker

### Tester et lancer

- cloner le repository : `git@github.com:Otabiel/Web_Infrastructure.git` SSH `h`
- `https://github.com/Otabiel/Web_Infrastructure.git` HTTPS
- Ce déplacer à la racine du projet
- Lancer la commande `docker build -t nom_a_choix docker-images/apache-php-image/` pour construire l'image docker du serveur apache avec le contenu du site, du dossier `src/`
- - Linux : `docker run -d nom_a_choix`
  - Autres : `docker run -d -p 9090:80 nom_a_choix` (Le numéro de port peut être changé)
- Il faut récupérer le `NAMES` de notre docker avec la commande suivante : `docker ps` ![img](https://cdn.discordapp.com/attachments/684112908958957577/847790722224095272/unknown.png)
- On récupère l'adresse IP avec la commande `docker logs NAMES` ![img](https://cdn.discordapp.com/attachments/684112908958957577/847792149289500672/unknown.png)Dans cet exemple l'adresse ip est 172.17.0.2
- Pour modifier la configuration apache dockerisé, il faut lancer la commande `docker exec -it NAMES /bin/bash`. Ceci va nous lancer une session du terminal sur le docker. Ensuite, on peut se déplacer dans `/etc/apach2`avec la commande `cd`et modifier ce qu'on souhaite.

<div style="page-break-after: always; break-after: page;"></div>

## Etape 2 : HTTP dynamique

### Infrasctructure

Dans le répertoire `./docker-images/express-image/`

dossier `src/` qui contient le fichier source de l'application JavaScript

Dockerfile :

```dockerfile
FROM node:15.13.0
COPY src/ /opt/app
CMD ["node", "/opt/app/index.js"]
```

CMD : instruction pour exécuter une commande dans le container en running. Exécute la commande quand l'image docker est déployée.

### Tester et lancer

- Il faut consruire les dépendances node avec la commande `npm install`depuis le répertoire `./docker-images/express-image/src`. (si on n'a pas la commande npm -> `https://www.npmjs.com/`)
- Ensuite il faut construire le container avec la commande `docker build -t nom_a_choix docker-images/express-image/` depuis la racine du projet.
- Lancer le container avec la commande `docker run -d -p 9091:3000 nom_a_choix`.
- Lister les adresse ip avec la commande `ip addr`pour trouver celle de docker.
- Accéder à l'adresse ip de docker via un navigateur comme tel `http://172.17.0.1:9091` 
- Pour terminer l'exécution du container, utiliser la commande `docker kill NAMES`. `NAMES`se trouve avec la commande `docker ps`.

## Etape 3 : Proxy

### Infrastructure

Dans le répertoir `./docker-images/apache-reverse-proxy`

Dockerfile :

```dockerfile
FROM php:7.2-apache
COPY conf/ /etc/apache2

RUN a2enmod proxy proxy_http
RUN a2ensite 000-* 001-*
```

RUN : Instruction pour exécuter une commande au-dessus de l'image docker actuelle. Exécuté lors de la construction de l'image.

Script build et script run permettant de construire et d'éxécuter les containers.

Un dossier conf/ contenant les configuration pour les sites.

Attention : les IPs sont hardcoder et doiventdonc toujours être vérifiées pour correspondre au contenu du fichier de configuration `001-reverse-proxy.conf`contenu dans `./docker-images/apache-reverse-proxy/conf/sites-available`.

### Tester et lancer

- Avant de faire quoique ce soit, vérifier qu'aucun autre container soit actif avec la commande `docker ps`. Vu qu'on a hardcodé les adresse IP, cela pourrait poser problème si d'autres containers utilise les adresse IP hardcodées déjà utilisées. Pour kill les container en cours, utiliser la commande `docker kill NAMES`. Enfin, on clean le tout avec la commande `docker rm docker ps -qa`.
- Exécuter le script `./docker-images/apache-reverse-proxy/build.sh`pour construire les containers.
- Exécuter le script `./docker-images/apache-reverse-proxy/run.sh`pour run les containers.
- Depuis un terminal (linux) aller modifier le fichier hosts en lançant `sudo !!`ou `sudo nano /etc/hosts`et ajouter une ligne contenant notre adresse IP et le nom du domaine tel que : `192.168.1.123 address.res.ch`.
- Accéder au site dynamique express `http://address.res.ch:8080/api/address/`.

## Etape 4 : Ajax avec jQuery

Créer un fichier javascript afin de pouvoir exécuter une fonction jQuerry. Le script en question : `address.js`

```javascript
$(function() {
    
    function loadAddress() {
        $.getJSON( "/api/address/", function( address ) {
            var message = address[0].adress + " " + address[0].city + " " + address[0].country;
            $(".hereToModify").text(message);
        });    
    };
    
    loadAddress();
    setInterval( loadAddress, 2000 );

});
```

On remarque que la fin de la fonction loadAddress() on viens écrire le "message" à un "flag" hereToModify. Ce flag correspond enfaite à la class d'une balise span englobant une partie de notre page html :

```html
<h2><span class="hereToModify">We are team of talented designers making websites with Bootstrap</span></h2>
```

et on a dû ajouter à la fin du fichier index.html les includes de notre script créé ainsi que l'include du module jQuerry :

```html
<!-- jQuery module -->
  <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js" type="text/javascript"></script>
<!-- Custom script -->
  <script src="assets/js/address.js"></script>
```

La mise en place de cela n'a pas impliqué de changement dans l'exécution de nos docker.

Nous avons tout de même ajouté, dans les dockerfile, l'installation automatique de nano afin de facilité nos tests sur les containers avant de les faire dans notre implémentation.

```dockerfile
RUN apt-get update && \
    apt-get install -y nano 
```

## Etape 5 : configuration dynamique du reverse proxy

Nous avons rajouter deux fichier a notre environnement. Le premier permettant de configurer via un script php nos adresses ip par le biais des variables d'environnement. Ce qui nous permet de enfin régler le fait de hardcoder nos adresses ip dans les fichiers de configuration. `./docker-images/apache-reverse-proxy/templates/config-tempate.php`

```php
<?php 
    $dynamic_app = getenv('DYNAMIC_APP');
    $static_app = getenv('STATIC_APP');
?>


<VirtualHost *:80>
    ServerName address.res.ch

    ProxyPass '/api/address/' 'http://<?php print "$dynamic_app"?>/'
    ProxyPassReverse '/api/address/' 'http://<?php print "$dynamic_app"?>/'

    ProxyPass '/' 'http://<?php print "$static_app"?>/'
    ProxyPassReverse '/' 'http://<?php print "$static_app"?>/'


</VirtualHost>
```

Nous avons également créer une "surcharge" du fichier apache2-foreground afin de pouvoir utiliser la génération de notre script php pour remplacer la config précédemment faîtes: 

```php
#!/bin/bash
set -e

: "${APACHE_CONFDIR:=/etc/apache2}"
: "${APACHE_ENVVARS:=$APACHE_CONFDIR/envvars}"
if test -f "$APACHE_ENVVARS"; then
    . "$APACHE_ENVVARS"
fi

# Apache gets grumpy about PID files pre-existing
: "${APACHE_RUN_DIR:=/var/run/apache2}"
: "${APACHE_PID_FILE:=$APACHE_RUN_DIR/apache2.pid}"
rm -f "$APACHE_PID_FILE"


php /var/apache2/templates/config-template.php > /etc/apache2/sites-available/001-reverse-proxy.conf

rm -f /var/run/apache2/apache2.pid
exec apache2 -DFOREGROUND
```

nous avons ensuite ajouter deux lignes au dockerfile 

```dockerfile
COPY apache2-foreground /usr/local/bin/
COPY templates /var/apache2/templates
```

Pour tester il faut, si des containers des étapes précédents sont toujours en cours de lancement les arrêtés avec docker kill puis d'exécuter la commande : 

```shell
docker rm `docker ps -qa`
```

 Puis il nous suffit comme avant de lancé les script build et run, mais de spécifier en attributs les adreese ip : 

```
./docker-images/apache-reverse-proxy/build.sh
./docker-images/apache-reverse-proxy/run.sh 172.17.0.2 172.17.0.3
```

## Étape 6 : Load balancing: multiple server nodes

Le load balancing désigne le processus de répartition d'un ensemble de tâches sur un ensemble de ressources. Donc dans notre infrastructure nous allons testé cela en dupliquant notre site statique apache et notre script javascript sur 	express.

Afin de voir des différence entre les deux sites nous avons dupliqué `apache_php_image` afin de faire apparaître une différence visuel.

Premièrement nous alons donc modifier notre script php d'allocation d'ip dynamique en lui ajoutant la possiblité d'avoir du choix dans ces ressources 
*src: https://stackoverflow.com/questions/28663033/how-can-i-set-up-a-load-balancer-for-multiple-virtual-hosts-apache/28664733*

```php+HTML
<?php
    $static_app_01 = getenv('STATIC_APP_01');
    $static_app_02 = getenv('STATIC_APP_02');
    $dynamic_app_01 = getenv('DYNAMIC_APP_01');
    $dynamic_app_02 = getenv('DYNAMIC_APP_02');
?>

<VirtualHost *:80>
    ServerName address.res.ch
    
    <Proxy balancer://dynamic_app>
        BalancerMember 'http://<?php print "$dynamic_app_01"?>'
        BalancerMember 'http://<?php print "$dynamic_app_02"?>'
    </Proxy>

    <Proxy balancer://static_app>
        BalancerMember 'http://<?php print "$static_app_01"?>'
        BalancerMember 'http://<?php print "$static_app_02"?>'
    </Proxy>

    ProxyPass '/api/address/' 'balancer://dynamic_app/'
    ProxyPassReverse '/api/address/' 'balancer://dynamic_app/'

    ProxyPass '/' 'balancer://static_app/'
    ProxyPassReverse '/' 'balancer://static_app/'
</VirtualHost>
```

Donc comme on peut le voir on a rajouter les balises "Proxy" qui va permettre de mettre un balancer entre les deux ip fournie pour nos deux api dynamique et nos deux sites statiques.

Nous avons ensuite dû ajouter aux Dockerfile du proxy l'activation du load balancing en ajoutant : `proxy_balancer lbmethod_byrequests` à la commande `RUN a2enmod` pour activé le proxy balancing

```dockerfile
FROM php:7.2-apache

RUN apt-get update && \
    apt-get install -y nano

COPY apache2-foreground /usr/local/bin/
COPY templates /var/apache2/templates
COPY conf/ /etc/apache2

RUN a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests
RUN a2ensite 000-* 001-*
```

On a ensuite modifié les script de construction des containers et de leur lancement.

Pour testé il faut comme précédement, si les containers sont toujours en cours d'exécution, les arrêter avec `docker kill` et lancer la commande :

```shell
docker rm `docker ps -qa`
```

Ensuite lancé la construction des containers et l'exécution des sites statiques et des applications dynamique avec les scripts fournis : 

```shell
$ ./docker-images/apache-reverse-proxy/build.sh
$ ./docker-images/apache-reverse-proxy/run.sh
```

Si nécessaire, par la on entends si d'autres containers occupe potentiellement des adresses IP. On vous conseil de vérifier les adresses ip avec : 

```shell
$ docker inspect apache-static-1 | grep -i ipaddr
$ docker inspect apache-static-2 | grep -i ipaddr
$ docker inspect express-dynamic-1 | grep -i ipaddr
$ docker inspect express-dynamic-2 | grep -i ipaddr
```

Et ensuite lancé avec le script fourni le proxy : 

```shell
$ ./docker-images/apache-reverse-proxy/run_proxy.sh 172.17.0.2 172.17.0.3 172.17.0.4 172.17.0.5
```

Et si on ouvre deux fois les adresses `address.res.ch:8080` on obitent deux pages, donc le load balancing fonctionne bien.

![](/home/bruno/Bureau/Cours/RES/Web_Infrastructure/img/load_balancing1.png)

![](/home/bruno/Bureau/Cours/RES/Web_Infrastructure/img/load_balancing_2.png)

Mais actuellement lorsque que l'on charge une page nous ne sommes pas garantit de rester sur le même serveur, nous pouvons être rebalancer entre le "[1]" et le "[2]".

## Étape 6 : Load balancing, round-robin vs sticky sessions

Nous devons mettre en place des "sticky sessions" afin de ne plus changer aléatoirement de serveur a chaque refresh, mais de garder sa session sur le même serveur.

Pour ce faire nous avons modifier le script php pour y ajouter un système de "sticky sessions" par Id de route via la ligne 22 `ProxySet stickysession=ROUTEID`. Et nous retenons ce dernier dans un cookie "Header" ligne 11.
*src: http://docs.motechproject.org/en/latest/deployment/sticky_session_apache.html#method-1-using-existing-session-cookie*

```php+HTML
<?php
    $static_app_01 = getenv('STATIC_APP_01');
    $static_app_02 = getenv('STATIC_APP_02');
    $dynamic_app_01 = getenv('DYNAMIC_APP_01');
    $dynamic_app_02 = getenv('DYNAMIC_APP_02');
?>

<VirtualHost *:80>
    ServerName address.res.ch
    
    Header add Set-Cookie "ROUTEID=.%{BALANCER_WORKER_ROUTE}e; path=/" env=BALANCER_ROUTE_CHANGED

    <Proxy balancer://dynamic_app>
        BalancerMember 'http://<?php print "$dynamic_app_01"?>'
        BalancerMember 'http://<?php print "$dynamic_app_02"?>'
    </Proxy>

    <Proxy balancer://static_app>
        BalancerMember 'http://<?php print "$static_app_01"?>' route=1
        BalancerMember 'http://<?php print "$static_app_02"?>' route=2
        ProxySet stickysession=ROUTEID
    </Proxy>

    ProxyPass '/api/address/' 'balancer://dynamic_app/'
    ProxyPassReverse '/api/address/' 'balancer://dynamic_app/'

    ProxyPass '/' 'balancer://static_app/'
    ProxyPassReverse '/' 'balancer://static_app/'
</VirtualHost>
```

Et nous avons donc activé les header dans le les options d'apache dans le dockerfile : 

```dockerfile
FROM php:7.2-apache

RUN apt-get update && \
    apt-get install -y nano

COPY apache2-foreground /usr/local/bin/
COPY templates /var/apache2/templates
COPY conf/ /etc/apache2

RUN a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests headers
RUN a2ensite 000-* 001-*
```

Pour testé il faut comme précédement, si les containers sont toujours en cours d'exécution, les arrêter avec `docker kill` et lancer la commande :

```shell
docker rm `docker ps -qa`
```

Ensuite lancé la construction des containers et l'exécution des sites statiques et des applications dynamique avec les scripts fournis : 

```shell
$ ./docker-images/apache-reverse-proxy/build.sh
$ ./docker-images/apache-reverse-proxy/run.sh
```

Si nécessaire, par la on entends si d'autres containers occupe potentiellement des adresses IP. On vous conseil de vérifier les adresses ip avec : 

```shell
$ docker inspect apache-static-1 | grep -i ipaddr
$ docker inspect apache-static-2 | grep -i ipaddr
$ docker inspect express-dynamic-1 | grep -i ipaddr
$ docker inspect express-dynamic-2 | grep -i ipaddr
```

Et ensuite lancé avec le script fourni le proxy : 

```shell
$ ./docker-images/apache-reverse-proxy/run_proxy.sh 172.17.0.2 172.17.0.3 172.17.0.4 172.17.0.5
```

Et on ouvrant une page internet à l'adresse `address.res.ch` on remarque qu'on ne quittera plus la page sur laquelle nous avons été dirigé sauf si l'on supprime nos cookie pour pouvoir en recevoir un avec une nouvelle route id.

## Étape 7  : Gestion de cluster dynamique

Nous avons ajouter dans le script php :

```
<Location "/balancer-manager/">
	SetHandler balancer-manager
</Location>
    
ProxyPass '/balancer-manager/' !    
```

*src: https://httpd.apache.org/docs/2.4/howto/reverse_proxy.html "Gestion du répartiteur de charge"*

Qui comme les sources le montre nous permet d'activer la gestion du cluster dynamique.

Pour testé il faut comme précédement, si les containers sont toujours en cours d'exécution, les arrêter avec `docker kill` et lancer la commande :

```shell
docker rm `docker ps -qa`
```

Ensuite lancé la construction des containers et l'exécution des sites statiques et des applications dynamique avec les scripts fournis : 

```shell
$ ./docker-images/apache-reverse-proxy/build.sh
$ ./docker-images/apache-reverse-proxy/run.sh
```

Si nécessaire, par la on entends si d'autres containers occupe potentiellement des adresses IP. On vous conseil de vérifier les adresses ip avec : 

```shell
$ docker inspect apache-static-1 | grep -i ipaddr
$ docker inspect apache-static-2 | grep -i ipaddr
$ docker inspect express-dynamic-1 | grep -i ipaddr
$ docker inspect express-dynamic-2 | grep -i ipaddr
```

Et ensuite lancé avec le script fourni le proxy : 

```shell
$ ./docker-images/apache-reverse-proxy/run_proxy.sh 172.17.0.2 172.17.0.3 172.17.0.4 172.17.0.5
```

Et en ouvrant une page internet à l'adresse `http://address.res.ch:8080/balancer-manager/` on retrouve bien notre gestionnaire désiré.

![](/home/bruno/Bureau/Cours/RES/Web_Infrastructure/img/cluster-manger-dynamic.png)

## Étape 8 : Gestion d'une interface utilisateur

Nous n'avons rien du mettre en place pour pouvoir avoir une interface web nous permettant d'avoir un visuel sur l'implémentation de container mis en place.

Pour pouvoir utiliser une interface utilisateur pour pouvoir gérer les containers plus facilement il faut comme précédement, si les containers sont toujours en cours d'exécution, les arrêter avec `docker kill` et lancer la commande :

```shell
docker rm `docker ps -qa`
```

Ensuite lancé la construction des containers et l'exécution des sites statiques et des applications dynamique avec les scripts fournis : 

```shell
$ ./docker-images/apache-reverse-proxy/build.sh
$ ./docker-images/apache-reverse-proxy/run.sh
```

Si nécessaire, par la on entends si d'autres containers occupe potentiellement des adresses IP. On vous conseil de vérifier les adresses ip avec : 

```shell
$ docker inspect apache-static-1 | grep -i ipaddr
$ docker inspect apache-static-2 | grep -i ipaddr
$ docker inspect express-dynamic-1 | grep -i ipaddr
$ docker inspect express-dynamic-2 | grep -i ipaddr
```

Et ensuite lancé avec le script fourni le proxy : 

```shell
$ ./docker-images/apache-reverse-proxy/run_proxy.sh 172.17.0.2 172.17.0.3 172.17.0.4 172.17.0.5
```

Pour enfin lancé la commande suivante : 

```shell
$ docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer
```

Puis de ce connecter depuis un navigateur au site `localhost:9000`.

Cela vous ammène sur le portail portainer.io ou vous devrez vous créer un compte administrateur 

![](/home/bruno/Bureau/Cours/RES/Web_Infrastructure/img/portainer_register.png)

Une fois connectez, vous vous retrouverez sur une page pour choisir qu'elle environnement vous voulez administrer, sélectionnez "Local"
![](/home/bruno/Bureau/Cours/RES/Web_Infrastructure/img/select_local.png)

Sur le menu principal vous verez vos envrionnement à manager, normalement qu'un seul qui est celui en local. Vous pouvez cliquer dessus
![](/home/bruno/Bureau/Cours/RES/Web_Infrastructure/img/1.png)

Ensuite vous verez le résumé de l'envrionnement et ce qui le compose. Cliquer sur "Containers" pour pouvoir voir les containers.
![](/home/bruno/Bureau/Cours/RES/Web_Infrastructure/img/2.png)

Pour finalement arrivé sur l'écran de gestion des containers.
![](/home/bruno/Bureau/Cours/RES/Web_Infrastructure/img/3.png)

