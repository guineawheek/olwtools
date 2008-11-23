#!/usr/bin/perl

################################################################################
#pRadius Web interface
#Copyright (C) 2006  Olivier Duclos <olivierduclos@oliwer.net>
#
#This program is free software; you can redistribute it and/or
#modify it under the terms of the GNU General Public License
#as published by the Free Software Foundation; either version 2
#of the License, or any later version.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program; if not, write to the Free Software
#Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
################################################################################

use strict;
use CGI qw/:standard/;
use pRadius;


## C O N F I G ###################################################################################
our $RADDB = '/etc/freeradius/users';           # le fichier users de freeradius                 #
our $RADACCT = '/var/log/freeradius/radacct/';  # Le repertoir des logs                          #
our $RSTCMD = '/etc/init.d/freeradius restart'; # commande pour redémarrer freeradius            #
## E N D  C O N F I G ############################################################################



print header('text/html');

open(STDERR, ">&STDOUT"); # <-- very useful for debuging

our $title;           # Ce sont les deux seuls éléments
our $content;         # dynamiques dans chaque page.


## La page d'accueil ##
if (url_param('mode') eq '')
{
   $title = 'Que voullez-vous faire ?';
   $content = <<FIN
   <a href="radius.cgi?mode=list">Afficher la liste des utilisateurs</a>
   <br /><br />
   <a href="radius.cgi?mode=add">Ajouter un nouvel utilisateur</a>
   <br /><br />
   <a href="radius.cgi?mode=del">Supprimer un utilisateur</a>
   <br /><br />
   <a href="radius.cgi?mode=mod">Modifier les propri&eacute;t&eacute;s d'un utilisateur</a>
   <br /><br />
   <a href="radius.cgi?mode=search">Rechercher un utilisateur particulier</a>
   <br /><br />
   <a href="radius.cgi?mode=logs">Consulter les logs</a>
   <br />
FIN
}


## le listing des utilisateurs ##
if (url_param('mode') eq 'list')
{
    $title = "Liste des utilisateurs";
    my @usersList = @{pRadius::listUsers($RADDB)};
    my $line;
    foreach $line (@usersList)
    {
       $content .= ("&nbsp;&nbsp;<a href=\"radius.cgi?mode=mod&user=$line\">$line</a><br />\n");
            # ." <a href=\"radius.cgi?mode=del&user=$line\"> X</a><br />\n");
    }
    print "<br />\n";
}


## ajouter un utilisateur ##
if (url_param('mode') eq 'add')
{
    $title = "Ajouter un utilisateur";
    
    if (param('userName') eq '')
    {
       $content = <<"FIN"
<form method="post" action="radius.cgi?mode=add" name="addUserForm">

    <label>Nom de l'utilisateur : </label><br />
	<input type="text" name="userName"  size="30" value="" />
	<br /><br />
	<label>Mot de passe : </label><br />
	<input type="text" name="userPass"  size="30" value="" />
	<br /><br />
	<label>Commentaire : </label><br />
	<input type "text" name="comment"   size="30" value="" />
	<br /><br />
	<label>Type d'authentification : </label><br />
	<input type="text" name="authType"  size="30" value="Local" />
	<br /><br />
	<label>Type de service : </label><br />
	<input type="text" name="serviceType"  size="30" value="Callback-Login-User" />
            
	&nbsp;&nbsp; <input type="submit" value="Valider" />
			      
</form>
<br />
FIN
    }
    else
    {
       my $user = param('userName');
       my $pass = param('userPass');
       my $comment = param('comment');
       my $authType = param('authType');
       my $srvcType = param('serviceType');
       if (pRadius::addUser($user, $comment, $authType, $pass, $srvcType, $RADDB))
          { $content = "Nouvel utilisateur enregistré avec succès.<br />\n"; }
       else { $content = "Le nouvel utilisateur n'a pas pu etre enregistré.<br />\n"; }
    }
}


## Supprimer un utilisateur ##
if (url_param('mode') eq 'del')
{
    $title = "Supprimer un utilisateur";
    
    if (param('userName') eq '' && url_param('user') eq '')
    {
       $content = <<"FIN"
<form method="post" action="radius.cgi?mode=del" name="delUserForm">

	<label>Nom de l'utilisateur : </label><br />
	<input type="text" name="userName"  size="30" value="" />
	&nbsp;&nbsp; <input type="submit" value="Supprimer" />

</form>
<br />
FIN
    }
    else
    {
       my $user = param('userName') . url_param('user');
       if (pRadius::delUser($user, $RADDB))
          { $content = "Utilisateur supprimé.<br />\n"; }
       else { $content = "L'utilisateur n'a pas pu etre supprimé.<br />\n"; }
    }
}


## Affiche un utilisateur (afin de le modifier) ##
if (url_param('mode') eq 'mod')
{
    $title = "Modifier un utilisateur";
    
    if (param('userName') eq '' && url_param('user') eq '')
    {
       $content = <<"FIN"
<form method="post" action="radius.cgi?mode=mod" name="Form">

	<label>Nom de l'utilisateur : </label><br />
	<input type="text" name="userName"  size="30" value="" />
	&nbsp;&nbsp; <input type="submit" value="Modifier" />

</form>
<br />
FIN
    }
    else
    {
       my $user = param('userName') . url_param('user');
       if (pRadius::testUser($user, $RADDB))
       {
          my @infos = @{pRadius::getUser($user, $RADDB)};
	  my $userPass = $infos[1];
	  my $comment = $infos[2];
	  $content = <<"FIN"
<form method="post" action="radius.cgi?mode=modif" name="modUserForm">

    <label>Nom de l'utilisateur : </label><br />
	<input type="text" name="userName"  size="30" value="$user" />
	<br /><br />
	<label>Mot de passe : </label><br />
	<input type="text" name="userPass"  size="30" value="$userPass" />
	<br /><br />
	<label>Commentaire : </label><br />
	<input type "text" name="comment"   size="30" value="$comment" />
	<br /><br />
	<label>Type d'authentification : </label><br />
	<input type="text" name="authType"  size="30" value="Local" />
	<br /><br />
	<label>Type de service : </label><br />
	<input type="text" name="serviceType"  size="30" value="Callback-Login-User" />
            
	&nbsp;&nbsp; <input type="submit" name="modifier" value="Modifier" />
	&nbsp;&nbsp; <input type="submit" name="supprimer" value="Supprimer" />
			      
</form>
<br />
FIN
       }
       else
       {
          $content = "Nom d'utilisateur inconnu.<br />";
       }
    }
}


## Modifier un utilisateur ##
if (url_param('mode') eq 'modif')
{
   $title = "Modification de l'utilisateur";
   
   if (param('userName') eq '')
   {
      print "<script language=\"javascript\">window.location=\"radius.cgi?mode=mod\"</script>";
   }
   else
   {
      if (param('supprimer')) # Racourcis pour supprimer un utilisateur
      {
         my $user = param('userName');
	 #print redirect("radius.cgi?mode=del&user=$user"); # ne peut pas marcher car on a déjà envoyé un header
	 print "<script language=\"javascript\">window.location=\"radius.cgi?mode=del&user=$user\"</script>";
      }
      else
      {
         my $userName = param('userName');
         my $comment = param('comment');
         my $authType = param('authType');
         my $userPass = param('userPass');
         my $srvcType = param('serviceType');
         if (pRadius::modUser($userName, $comment, $authType, $userPass, $srvcType, $RADDB))
         {
            $content = "L'utilisateur a bien été modifié.";
         }
         else
         {
            $content = "L'utilisateur n'a pas pu etre modifié.";
         }
      }
   }
}


## Chercher un utilisateur ##
if (url_param('mode') eq 'search')
{
    $title = "Rechercher un utilisateur";
    
    if (param('userName') eq '')
    {
       $content = <<"FIN"
<form method="post" action="radius.cgi?mode=search" name="Form">

	<label>Nom de l'utilisateur : </label><br />
	<input type="text" name="userName"  size="30" value="" />
	&nbsp;&nbsp; <input type="submit" value="Chercher" />

</form>
<br />
FIN
   }
   else
   {
      my $user = param('userName');
      my @usersList = @{pRadius::listUsers($RADDB)};
      my $line;
      foreach $line (@usersList)
      {
         if ($line =~ /$user/i)
	 {
	   $content .= "&nbsp;&nbsp;<a href=\"radius.cgi?mode=mod&user=$line\">$line</a><br />\n";
	 }
      }
      print "<br />\n";
   }
}


## Afficher les logs ##
if (url_param('mode') eq 'logs')
{
   $title = "Consultation des logs";
   
   if (param('date') eq '')
   {
      $content = <<"FIN"
<form method="post" action="radius.cgi?mode=logs" name="Form">

	<label>Entrez la date du log à consulter (AAAAMMJJ) : </label><br />
	<input type="text" name="date"  size="30" value="" />
	&nbsp;&nbsp; <input type="submit" value="Consulter" />

</form>
<br />
FIN
   }
   else
   {
      my $date = param('date');
      my @log;
      if (@log = @{pRadius::getLogs($RADACCT, $date)})
      {
	 $content = join ('<br />', @log);
      }
      else
      {
         $content = "Pas de logs pour cette date.";
      }
   }
}


## Redémarrage du service freeradius afin de prendre en compte les changements apportés ##
if (url_param('mode') eq 'apply')
{
   $title = "Application des changements";
   
   @ENV{PATH} = '/bin:/usr/sbin:/sbin'; # <-- security !
   
   if (pRadius::apply($RSTCMD) != -1)
   { $content = "Service freeradius redémarré avec succès." }
   else
   { $content = "Le service n'a pu etre redémarré." }
}




	##########################
	## START OF STATIC HTML ##
	##########################


## Début de page ##
print <<"FIN";
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
    <title> FreeRadius Users Admin </title>
    <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />
    <style>
	*{margin:0; padding:0;}
	
	body{
		font: 75% Verdana,Tahoma,Arial,sans-serif;
		line-height:1.4em;
		color:#101030;
		background:#aaaaaa;
	}
	
	a{
		color:#101030;
		text-decoration:none;
		background-color:inherit;
	    border-bottom: 1px dotted #aaaaaa;
	}
	
	a:hover{
		color:#6a5a24; 
		text-decoration:none; 
		background-color:inherit;
	}
	
	a img{
		border:none;
	}
	
	p{
		padding:0 0 1.6em 0;
	}
	
	p form{
		margin-top:0; 
		margin-bottom:20px;
	}
	
	img.left,img.center,img.right{
		padding:4px; 
		border:1px solid #a0a0a0;
	}
	
	img.left{
		float:left; 
		margin:0 12px 5px 0;
	}
	
	img.center{
		display:block; 
		margin:0 auto 5px auto;
	}
	
	img.right{
		float:right; 
		margin:0 0 5px 12px;
	}
	
	#container{
		width:756px;
		margin:20px auto;
		text-align:left;
		background:#f5f5fc;
		color:#303030;
		position:relative;
	}
	
	
	#header{
		height:40px;
		width:100%;
		background:#151540;
		color:#ffffff;
	}
	
	#header h1{
	    font-weight: bold;
	    font-style: italic;
		font-size: 150%;
	    color: #efeffa;
		position: absolute;
		margin-top: 10px;
	    background-color: #151540;
	    padding: 15px;
	    letter-spacing: 1px;
	    float: left;
	}
	
	#topNavigation{
		height:2em;
		background:#151540;
		color:#ffffff;
	}
	
	#topNavigation li{
		float:right;
		list-style-type:none;
		white-space:nowrap;
	}
	
	#topNavigation li a{
		display:block;
		padding:3px 6px;
		font-weight:normal;
		text-transform:lowercase;
		text-decoration:none;
		background-color:#483802;
		color: #ffffff;
		border-right: 1px solid #151540;
	    border-bottom: 0px;
	}
	
	* html #topNavigation a {
		width:1%;
	}
	
	#topNavigation .selected,#topNavigation a:hover{
		background:#464901;
		color:#ffffff;
		text-decoration:none;
	}
	
	#content{
		float:left;
		width: 580px;
		padding: 4px;
		margin: 2px;
		background-color: #fefefb;
	    color: #101030;
		border: 1px solid #e5e5f9;
	    text-align: justify;
	}
	
	.contentBox {
	    display: block;
	    padding: 10px;
		margin-bottom: 10px;
	    background-color: #eeffbb;
	    color: #333333;
	/* text-align: center;*/
	}
	
	#content p{
		padding: 5px;
	}
	
	.indent {
		text-indent: 20px;
	}
	
	#rightNavigation{
		float:left;
		width:150px;
		padding: 5px 0;
		line-height:1.4em;
		text-align:left;
	}
	
	
	#rightNavigation h2{
		display:block;
		margin:0 0 15px 0;
		font-weight:normal;
		text-align:left;
		color:#505050;
		background-color:inherit;
	}
	
	#rightNavigation p{
		margin:0 0 5px 0; 
	}
	
	#rightNavigation a{
		display: block;
	    border: 0px;
	}
	
	#footer{
		clear:both;
		width:100%;
		font-size: 90%;
		color:#ffffff;
		background:#151540;
		text-align:center;
	}
	
	#footer p{
		padding:0; 
		margin:0; 
		text-align:center;
	}
	
	#footer a{
		color:#f0f0f0; 
		background-color:inherit; 
		font-weight:bold;
	}
	
	#footer a:hover{
		color:#ffffff; 
		background-color:inherit; 
		text-decoration: none;
	}
	
	.navBox{
		background-color: #f5f5fc;
	    color: #101030;
		padding-left:10px;
		padding-top: 5px;
		padding-bottom: 5px;
		line-height:1.6em;
	}
	
	h1 {
	    font-size: 130%;
		padding: 5px;
	}
	
	h2{
	    font-size: 120%;
		padding: 5px;
	}
	
	h3{
	    font-size: 110%;
		padding: 5px;
	}
	
	h4 {
	    font-size: 100%;
		padding: 5px;
	}
	
	input {
	    border: 1px solid #e5e5f9;
	}
    </style>
    <script language="javascript" type="text/javascript">
    <!--
    function setFocus()
    {
       if (document.forms[0])
       {
          document.forms[0].elements[0].focus();
       }
       else
       {
          // rien a faire
       }
    }
    //-->
    </script>
</head>

<body onload="setFocus();">
	<div id="container" >
		<div id="header">
			<h1>FreeRadius Users Admin</h1>
		</div>
		<div id="topNavigation">
			<ul>
				<li><a href="http://www.netdiffusion.com" target="_blank">Netdiffusion</a></li>
				<li><a href="http://mail.netdiffusion.com:8383" target="_blank">Webmail</a></li>
				<li><a href="http://gweb.netdiffusion.com" target="_blank">Gweb</a></li>
			</ul>
		</div>

		<div id="content">
			<span class="contentBox">
				<h4>
FIN
print "				$title\n";
				
				
print <<"FIN";
				</h4>
			</span>
			<p>
FIN
print "				$content";


## Fin de page ##
print <<"FIN";
			</p>
		</div>

		<div id="rightNavigation">
			<div class="navBox">
				<a href="radius.cgi">Accueil</a>
				<a href="radius.cgi?mode=list">Liste</a>
				<a href="radius.cgi?mode=add">Ajouter</a>
				<a href="radius.cgi?mode=del">Supprimer</a>
				<a href="radius.cgi?mode=mod">Modifier</a>
				<a href="radius.cgi?mode=search">Rechercher</a>
				<a href="radius.cgi?mode=logs">Logs</a>
				<br />
				<strong><a href="radius.cgi?mode=apply">Appliquer</a></strong>
			</div>
		</div>
		<div id="footer"><a href="http://oliwer.net/pradius" target="_blank">pRadius</a></div>
	</div>
</body>
</html>
FIN
