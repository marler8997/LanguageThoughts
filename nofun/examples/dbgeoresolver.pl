#!/usr/bin/perl

# Arguments:
#    - gid (Group ID)
#

use strict;

use Google::GeoCoder::Smart;
use Mysql;

#
# Parse Command Line Arguments
#
my $ARGC = scalar(@ARGV);
if(scalar(@ARGV) != 1) {
    print STDERR "Expected 1 command line argument, you gave $ARGC\n";
    exit;
}
my $gid = $ARGV[0];
my $groupDataTable = "group".$gid."data";

#
# Create Google Geocode Object
#
my $geo = Google::GeoCoder::Smart->new();


#
# Go through database to resolve recoreds missing their location
#
my $mysql = Mysql->connect('localhost','capp','capp','');
my $mysqlResult = $mysql->query('SELECT addr,city,state FROM '.$groupDataTable.' WHERE loc IS NULL;');
if(!$mysqlResult) {die("mysql query failed");}


my $addressCount                 = 0;
my $addressesCachedInDatabase    = 0;
my $addressesResolved            = 0;
my $addressErrorsFromGoogle      = 0;
my $addressesWithMultipleResults = 0;

while (my @results = $mysqlResult->fetchrow()) {
    my $address = $results[0];
    my $city = $results[1];
    my $state = $results[2];

    $address  =~ s/^\s+//;;
    $address  =~ s/\s+$//;;
    $city     =~ s/^\s+//;;
    $city     =~ s/\s+$//;;
    $state    =~ s/^\s+//;;
    $state    =~ s/\s+$//;;

    my $fullAddress = "$address $city, $state";
    if($fullAddress =~ /;/) { die("SyntaxError: address '$fullAddress' contained a semi colon\n"); }

    #
    # Check Database For Address
    #
    my $mysqlGeocodeResult = $mysql->query('SELECT AsText(loc) FROM geocodes WHERE fulladdr=\''.$fullAddress.'\';');
    if(!$mysqlGeocodeResult) { goto GEOCODE_NOT_CACHED; }

    my @geocodeResult = $mysqlGeocodeResult->fetchrow();
    if(!@geocodeResult) { goto GEOCODE_NOT_CACHED; }

    my $geocode = @geocodeResult[0];
    $addressesCachedInDatabase++;

UPDATE_GEOCODE:
    print STDERR "UPDATING $fullAddress with $geocode\n";
    $mysql->query('UPDATE '.$groupDataTable.' SET loc=GeomFromText(\''.$geocode.'\') WHERE addr="'.$results[0].'" AND city="'.$results[1].'" AND state="'.$results[2].'";');
    next;

GEOCODE_NOT_CACHED:
    print STDERR "Retreiving Address '$fullAddress' from Google...\n";
    my ($results, $error, @results, $returnContent) = $geo->geocode("address"=>$fullAddress);

    if($error !~ /^OK$/) {
	print STDERR "Error: address '$fullAddress': Google returned the error '$error'\n";
	print "$fullAddress\n";
	$addressErrorsFromGoogle++;
	next;
    }
    
    if($results == 1) {
	my $lat = $results[0]{geometry}{location}{lat};
	my $lng = $results[0]{geometry}{location}{lng};
	$geocode = "POINT($lat $lng)";
	
	#Cache in geocodes database
	$mysql->query("INSERT INTO geocodes VALUES('$fullAddress',GeomFromText('$geocode'));");


	$addressesResolved++;
	goto UPDATE_GEOCODE;
    }
    
    if($results > 1) {
	print STDERR "Warning: address '$fullAddress': Received $results results:\n";
	for(my $i=0;$i < $results; $i++) {
	    my $lat = $results[$i]{geometry}{location}{lat};
	    my $lng = $results[$i]{geometry}{location}{lng};
	    print STDERR "$lat $lng\n";
	}
	print "$fullAddress\n";
	$addressesWithMultipleResults++;
	next;
    }

    # $results <= 0
    print STDERR "Error: address '$fullAddress': Google did not return an error but there are no results\n";
    print "$fullAddress\n";
    $addressErrorsFromGoogle++;
    
} continue { $addressCount++; }


print STDERR "-----------------------------------------\n";
print STDERR "Total addresses processed         | $addressCount\n";
print STDERR "-----------------------------------------\n";
print STDERR "Addresses found in cache          | $addressesCachedInDatabase\n";
print STDERR "Addresses resolved from Google    | $addressesResolved\n";
print STDERR "Errors from Google                | $addressErrorsFromGoogle\n";
print STDERR "Addresses with multiple results   | $addressesWithMultipleResults\n";

