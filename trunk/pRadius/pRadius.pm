package pRadius;

=head1 NAME

pRadius - Perl module for basic users management with FreeRadius.

=head1 SYNOPSIS

  use pRadius;

  my $RADDB = '/etc/freeradius/users';

  # Get the list of all users
  my @usersList = @{pRadius::listUsers($RADDB)};

  # Add a new user
  pRadius::addUser($user, $comment, $authType, $pass, $srvcType, $RADDB);

=head1 REQUIRES

Perl5.004

=head1 EXPORTS

Nothing

=head1 DESCRIPTION

This module is capable of creating, removing, getting information on a specified user, plus : getting a list of all users and getting logs for a specified date.

B<Be careful !> This module has been written for parsing files that respect the following syntax :

  # Comment line
  userName  Auth-Type := Local, User-Password == "password"
    Service-Type = Callback-login-user,

Notice there is a tabulation between userName and auth-type, and another one before Service-Type.
If your user file does not strictly respect this syntax, pRadius may not work properly. You can even lose important informations if you use the delUser() function (delete user).
So B<WATCH OUT !>

=head1 FUNCTIONS

Remember that in all the following functions, there are no default value for the arguments. Never. I strongly recommand you not to forget any argument in your function calls ;)
C<$RADDB> is the location of your freeradius user file. Generaly C</etc/freeradius/users>.

=over 4

=item pRadius::add ($userName, $comment, $authType, $userPass,
                    $srvcType, $RADDB)

An easy way to add a new user in your file. C<$srvcType> stands for "Service-Type". This function returns true or false.

=item pRadius::listUsers ($RADDB)

Returns a reference to an array with the name of all users.

=item pRadius::delUser ($userName, $RADDB)

Delete the specified user. Returns true or false. I hope that you respect the syntax for the users file that I told you upper.

=item pRadius::getUser ($userName, $RADDB)

Returns a reference to an array containing the user's name, the user's password and the comments for this user.

=item pRadius::testUser ($userName, $RADDB)

Checks if a user is present in the file. Returns true or false.

=item pRadius::modUser ($userName, $comment, $authType, $userPass,
                        $srvcType, $RADDB)

This function will delete the specified user from the file and the recreate him with the new given values.

=item pRadius::getLogs ($RADACCT, $date)

C<$RADACCT> is the path to your freeeadius logs directory. Probably C</var/log/freeradius/radacct/> (do not forget the / at the end).
C<$date> is the date of the log file you want to see. it is written following this pattern : YYYYMMDD (i.e 20060413).
The function will return a reference to an array containing the logs, ready to print on the screen.

=item pRadius::apply ($command)

To be aware of the changes you have done on the freeradius users file, the freeradius server have to be restarted. That is the goal of this function.
C<$command> is the command line that needs to be executed. It should be something like this : C</etc/init.d/freeradius restart>. Of course, you need to be root to do a such thing.

=back

=head1 TODO

Implement something to check if the users file syntax is correct.

Translations.

=head1 BUGS

Not yet...

=head1 COPYRIGHT

Copyright (c) 2006 Olivier Duclos. All rights reserved.

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 AUTHOR

Olivier Duclos C<olivierduclos@oliwer.net>

=cut


my $VERSION = "0.0.1";
use strict;


## Ajout d'un utilisateur ##
sub addUser
{
    my ($userName, $comment, $authType, $userPass, $srvcType, $RADDB) = @_;
    
    # On ne teste volontairement pas si l'utilisateur existe déjà.
    open FILE, ">> $RADDB" || die("Impossible d'ouvrir le fichier utilisateurs.\n");
    print FILE "# $comment\n$userName\tAuth-Type := $authType, User-Password == \"$userPass\"\n\tService-Type = $srvcType,\n"
      || die("Impossible d'ecrire dans le fichier utilisateurs.\n");
    close FILE;
}


## Lister tous les utilisateurs ##
sub listUsers
{
    my $RADDB = shift @_;
    my @usersList;
    my $user;
    
    open FILE, $RADDB || die("Impossible d'ouvrir le fichier utilisateurs.\n");
    while (my $line = <FILE>)
    {
        # si la ligne  commence par # ou tabulation
	if ( ($line =~ /^\#/) || ($line =~ /^\t/) ) {}
	else
	{
	   # on ne garde que la première chaine avant la tabulation
	   $user = ( split("\t", $line) )[0];
	   # et on l'ajoute à la liste des utilisateurs
	   push @usersList, $user;
	}
    }
    close FILE;
    return \@usersList;
}


## Supprimer un utilisateur ##
sub delUser
{
    my ($user, $RADDB) = @_;
    
    open FILE, $RADDB || die("Impossible d'ouvrir le fichier utilisateurs.\n");
    my @usersFile = <FILE>;
    
    # On teste si l'utilisateur est bien présent dans le fichier
    my $founded;
    my $line;
    foreach $line (@usersFile)
    {
       if ( $line =~ /^$user/ ) { $founded = 'yes' }
    }
    
    die("Cet utilisateur n'existe pas.\n") unless $founded eq 'yes';
    close FILE;
    
    # calcul de la taille du tableau
    my $size = scalar (@usersFile);
    
    # on cherche la ligne à supprimer et on delete tout
    for (my $i = 0; $i<$size; $i++)
    {
        if ($usersFile[$i] =~ /^$user/)
	{
	    delete $usersFile[$i - 1];
	    delete $usersFile[$i];
	    delete $usersFile[$i + 1];
	}
    }
    
    
    # on peut maintenant reécrire le fichier users
    open FILE, "> $RADDB" || die("Impossible d'ouvrir le fichier utilisateurs.\n");
    my $usersfile = join('', @usersFile);
    print FILE $usersfile || die("Impossible d'ecrire dans le fichier utilisateurs.\n");
    close FILE;
}


## Réccupère les informations d'un utilisateur ##
sub getUser
{
    my ($user, $RADDB) = @_;
    my $userPass;
    my $comments;
    my @result;
    
    open FILE, $RADDB || die("Impossible d'ouvrir le fichier utilisateurs.\n");
    my @usersFile = <FILE>;
    
    # On teste si l'utilisateur est bien présent dans le fichier
    my $founded;
    my $line;
    foreach $line (@usersFile)
    {
       if ( $line =~ /^$user/ ) { $founded = 'yes' }
    }
    
    die("Cet utilisateur n'existe pas.\n") unless $founded eq 'yes';
    close FILE;
    
    # calcul de la taille du tableau
    my $size = scalar (@usersFile);
    
    # on cherche la ligne de l'utilisateur
    for (my $i = 0; $i<$size; $i++)
    {
        if ($usersFile[$i] =~ /^$user/)
	{
	    $userPass = (split ('"', $usersFile[$i]) )[1];
	    $comments = (split ('# ', $usersFile[$i - 1]) )[1];
	    chomp $comments;
	    @result = ($user, $userPass, $comments);
	}
    }
    
    close FILE;
    return \@result;
}


## Teste si un utilisateur existe  ##
sub testUser
{
    my ($user, $RADDB) = @_;
    my $result = 0;
    
    open FILE, $RADDB || die("Impossible d'ouvrir le fichier utilisateurs.\n");
    
    while (my $line = <FILE>)
    {
       if ( $line =~ /^$user/ ) { $result = 1 }
    }
    close FILE;
    
    return $result;
}


## Modifier les cractéristiques d'un utilisateur ##
## (c'est juste un raccourci pour supprimer et recréer l'utilisateur) ##
sub modUser
{
    my ($userName, $comment, $authType, $userPass, $srvcType, $RADDB) = @_;
    
    if (delUser($userName, $RADDB))
    { addUser($userName, $comment, $authType, $userPass, $srvcType, $RADDB) }
}


## lecture des logs ##
sub getLogs
{
   my ($RADACCT, $date) = @_;
   our @log = undef;
   our $test = 0;
   
   opendir (DIR, $RADACCT) || die("Impossible d'ouvrir le répertoir des logs");
   my @passList = grep !/^\.\.?$/, readdir(DIR); #les logs sont triés par passerelle
   my $passerelle;
   foreach $passerelle (@passList)
   {
      if ( open(FILE, $RADACCT . $passerelle . "/detail-$date") )
      {
         push (@log, <FILE>);
	 close FILE;
	 $test = 1;
      }
   }
   closedir DIR;
   if ($test == 0) { @log = "Aucun log ne correspond à cette date." }
   return \@log;
}


## Redémarrage du service freeradius afin de prendre en compte les changements apportés ##
sub apply
{
   my $COMMAND = shift @_;
   system($COMMAND);
}


1;
