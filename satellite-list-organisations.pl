#!/usr/bin/perl
# satellite-list-organisations.pl 
#
# Used to list all organisations and all users within each organisation.  Tested on satellite 5.1 - 5.6
# 
# v1.0 

# Put your satellite server hostname in the below variable
my $HOST = 'satellite.server.com';

use Frontier::Client;
use IO::Prompt;

print "This utility lists organisations and all users within that organisation.\n";
print "------------------------------------------------------------------------\n";
print "You *MUST* login with the satellite administrator account\n";

my $user1 = prompt('Satellite User: ', -tty);
my $pass1 = prompt('      Password: ', -tty, -e => '*');

my $user = substr($user1, 0);
my $pass = substr($pass1,0);

my $client = new Frontier::Client(url => "http://$HOST/rpc/api");
my $session = $client->call('auth.login',$user, $pass);

my $orgs = $client->call('org.listOrgs', $session);
foreach my $org (@$orgs) {

    my $orgname = $org->{'name'};
    my $orgid = $org->{'id'};

    print $orgid . ":" . $orgname . "\n";

    my $orgusers = $client->call('org.listUsers', $session, $orgid);

    printf "%6.6s   %-16.16s  %-30.30s  %-40s\n", "Enable", "Login", "Name", "Email";

    foreach my $orguser (@$orgusers) {
#        print Dumper($orguser);
        printf "%6.6s   %-16.16s  %-30.30s  %-40s\n", $orguser->{'enabled'}, $orguser->{'login'}, $orguser->{'name'}, $orguser->{'email'};
    }

    print "\n\n";

}


$client->call('auth.logout', $session);
