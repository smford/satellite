#!/usr/bin/perl
# satellite-merge-chan.pl 
# Copies a channels packages and errata to another channel
#
# Username and password are the Satellite Server user, requires satellite v5.6 with all patches applied otherwise corruption of the database can occur.
# This is a known bug with satellite and the patches are neccessary.
#
# v1.0 
#

use Frontier::Client;
use IO::Prompt;
use Data::Dumper;

# Change the host below to point to your satellite v5.6 (fully patched) server
my $HOST = 'satellite.server.com';

my $client;
my $session;

my @syncchannels = (
    # channel set 1
    {   fresh   => "channel-test1",
        dev     => "dev-channel-test1",
        test    => "test-channel-test1",
        prod    => "prod-channel-test1",
    },

    # channel set 2
    {   fresh   => "rhel-x86_64-server-6-thirdparty-oracle-java",
        dev     => "dev-rhel-x86_64-server-6-thirdparty-oracle-java",
        test    => "test-rhel-x86_64-server-6-thirdparty-oracle-java",
        prod    => "prod-rhel-x86_64-server-6-thirdparty-oracle-java",
    },
);


my $user1 = prompt('Satellite User: ', -tty);
my $pass1 = prompt('      Password: ', -tty, -e => '*');

my $user = substr($user1, 0);
my $pass = substr($pass1,0);

ConnectSatellite();

for my $chanset (@syncchannels) {
    print "Synchronising: $chanset->{'fresh'} -> $chanset->{'dev'} -> $chanset->{'test'} -> $chanset->{'prod'}\n";

    # Copy fresh to dev channel
    MergePackages($chanset->{'fresh'}, $chanset->{'dev'});
    MergeErrata($chanset->{'fresh'}, $chanset->{'dev'});

    # Copy Dev to test channel
    MergePackages($chanset->{'dev'}, $chanset->{'test'});
    MergeErrata($chanset->{'dev'}, $chanset->{'test'});

    # Copy test to prod channel
    MergePackages($chanset->{'test'}, $chanset->{'prod'});
    MergeErrata($chanset->{'test'}, $chanset->{'prod'});

}

DisconnectSatellite();
exit;


sub MergePackages {
    my $channelfrom = $_[0];
    my $channelto = $_[1];
    print "Merging packages from $channelfrom to $channelto\n";
    my $numpackages = 0;
    my $packages = $client->call('channel.software.mergePackages', $session, $channelfrom, $channelto);
    foreach my $package (@$packages) {
       #print $numpackages . "\t" . $package->{'id'} . "\t" . $package->{'name'} . "\t" . $package->{'version'} . "  Release:" . $package->{'release'} . "\n";
       printf "%-5s  %-7s  %-30s  %-15s  %-15s\n", $numpackages, $package->{'id'}, $package->{'name'}, $package->{'version'}, $package->{'release'};
       $numpackages++;
    }

    if ($numpackages == 0) {
       print "** NO PACKAGES FOUND **\n"
    } else {
       print "==========\nTotal Packages: " . $numpackages . "\n";
    }
}


sub MergeErrata {
    my $channelfrom = $_[0];
    my $channelto = $_[1];
    print "Merging errata from $channelfrom to $channelto\n";
    my $numerrata = 0;
    my $erratas = $client->call('channel.software.mergeErrata', $session, $channelfrom, $channelto);
    foreach my $errata (@$erratas) {
       #print $numerrata . "\t" . $errata->{'id'} . "\t" . $errata->{'date'} . "\t" . $errata->{'advisory_type'} . $errata->{'advisory_name'} . "\t" . $errata->{'advisory_synopsis'} . "\n";
       printf "%-5s  %-7s  %-8s  %.8s  %-15s  %s\n", $numerrata, $errata->{'id'}, $errata->{'date'}, $errata->{'advisory_type'}, $errata->{'advisory_name'}, $errata->{'advisory_synopsis'};
       $numerrata++;
    }

    if ($numerrata == 0) {
       print "** NO ERRATA FOUND **\n"
    } else {
       print "==========\nTotal Errata: " . $numerrata . "\n";
    }
}


sub ConnectSatellite {
    print "Connecting to satellite ..";
    $client = new Frontier::Client(url => "http://$HOST/rpc/api");
    $session = $client->call('auth.login',$user, $pass);
}



sub DisconnectSatellite {
    $client->call('auth.logout', $session);
}
