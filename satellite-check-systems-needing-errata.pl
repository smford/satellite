#!/usr/bin/perl
# satellite-check-systems-needing-errata
# 
# This is a useful tool to identify all systems attached to satellite, regardless of organisation, which need particular errata applied.
# It is useful to quickly identify systems that need exploits, such as shellshock, heartbleed, etc.
# 
# The script assumes that within each organisation there is an admin account that the script can use, with each organisations admin account
# having the same password.  Without such an account, the script cannot log in to each organisation and check.
# 
# v1.0

use Frontier::Client;
use IO::Prompt;
use Data::Dumper;

use strict;
use warnings;

# Enter your satellite server host below
my $HOST = 'satellite.server.com';

# Each organisation needs to be entered below
my %organisations =(

# Example:
#    orgid,      {
#                "NAME", "Name of the Organisation",
#                "ADMIN", "admin-account-in-organisation",
#                 },


        1,      {
                "NAME", "Company 1",
                "ADMIN", "admin-company1",
                },

        2,      {
                "NAME", "Company 2",
                "ADMIN", "admin-company2",
                },

        3  ,    {
                "NAME", "Company 3",
                "ADMIN", "admin-company3",
                },

);


print "This tool will identify all systems attached to Satellite that need a particular Erratum applied.\nSystems attached to a cloned channel will not be identified unless you search for the name of the cloned errata instead.\n";
print "You MUST login as the Satellite Organisation Administrator\n";

my $user1 = prompt('Satellite User: ', -tty);
my $pass1 = prompt('      Password: ', -tty, -e => '*');

print "\nPlease Enter the Errata name to search for (for example \"RHSA-2014:0376\")\n";

my $advisory = prompt('Errata name: ', -tty);
$advisory = substr($advisory, 0);

#my $advisory = 'RHSA-2014:0376';
#my $advisory = 'CLA-2014:0376-1';

my $user = substr($user1, 0);
my $pass = substr($pass1, 0);



my $client = new Frontier::Client(url => "http://$HOST/rpc/api");
my $session = $client->call('auth.login',$user, $pass);
my $orgs = $client->call('org.listOrgs', $session);

# Have a list of all orgs, log out of session
$client->call('auth.logout', $session);
				
foreach my $org (@$orgs) {
    my $orgname = $org->{'name'};
    my $orgid = $org->{'id'};
    my $orguser = $organisations{$orgid}->{ADMIN};
    if ($orguser) {
        #print $orgid . "  " . $orgname . "  " . $orguser . "\n";
        my $session = $client->call('auth.login',$orguser, $pass);
        print $orgid . " " . $orgname . "\n";
        my $systems = $client->call('errata.listAffectedSystems', $session, $advisory);
        if (@$systems) {
            print "SysID       Satellite Name                       IP Address       Hostname                             Last Seen\n";
            print "-----------------------------------------------------------------------------------------------------------------\n";
            foreach my $system (@$systems) {
                my $systemidresults = $client->call('system.getId', $session, $system->{'name'});

                #print "2\n";
                foreach my $systemidresult (@$systemidresults) {
                    my $systemip = $client->call('system.getNetwork', $session, $systemidresult->{'id'});
                    my $lastcheckin = $client->call('system.getName', $session, $systemidresult->{'id'});
                    $lastcheckin = $lastcheckin->{'last_checkin'};
                    my $lastcheckin = sprintf("%04d-%02d-%02d", unpack('A4A2A2AA8', $lastcheckin->value()));
                    #print $systemidresult->{'id'} . "\t" . $systemidresult->{'name'} . "\t" . $systemip->{'ip'} . "\t" .  $systemip->{'hostname'}  . "\n";
                    printf "%10.10i  %-35.35s  %-15.15s  %-35.35s  %-8s\n", $systemidresult->{'id'}, $systemidresult->{'name'}, $systemip->{'ip'}, $systemip->{'hostname'}, $lastcheckin;
                }
                $numsystems++;
            }
            print "\n\n";
        } else {
            print "**** No systems affected\n\n";
        }
        $client->call('auth.logout', $session);
    } else {
        print "*** ERROR ***   Organisation: " . $orgid . " (" . $orgname . ") is not defined in the script, please add\n\n";
    }
}


				
