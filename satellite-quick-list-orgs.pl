#!/usr/bin/perl
# list-orgs
#
# v1.0 11Apr14  ccaastf

use Frontier::Client;
use IO::Prompt;
use Data::Dumper;

my $HOST = 'satellite.server.com';

print "This utility lists organisations and all users within that organisation.\n";
print "------------------------------------------------------------------------\n";
print "You *MUST* login with a satellite administrator account, eg: ucl-is\n";


my $user1 = prompt('Satellite User: ', -tty);
my $pass1 = prompt('      Password: ', -tty, -e => '*');

my $user = substr($user1, 0);
my $pass = substr($pass1,0);

my $client = new Frontier::Client(url => "http://$HOST/rpc/api");
my $session = $client->call('auth.login',$user, $pass);

my $orgs = $client->call('org.listOrgs', $session);
foreach my $org (@$orgs) {

    #print Dumper($org);

    my $orgname = $org->{'name'};
    my $orgid = $org->{'id'};

    print $orgid . "\t" . $orgname . "\n";

    my $orgusers = $client->call('org.listUsers', $session, $orgid);

    foreach my $orguser (@$orgusers) {
        #print Dumper($orguser);
        printf "\t- %-30.30s  %-40s\n", $orguser->{'name'}, $orguser->{'email'};
    }

    print "\n\n";

}


$client->call('auth.logout', $session);
