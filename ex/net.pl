#!/usr/bin/perl

use warnings;
use strict;
#use lib ('blib/lib');

sub VERBOSE () { 0 }

use Getopt::Lucid qw(:all);

my ($opt, $verbose,$domain,$username,$password,$host, $poe_td, $poe_te);

eval {$opt = Getopt::Lucid->getopt([
		Param("domain"),
		Param("username|u"),
		Param("password|p"),
		Param("host"),
		Counter("poe_debug|d"),
		Counter("poe_event|e"),
		Counter("xmpp_debug|x"),
		Counter("verbose|v"),
	])};
if($@) {die "ERROR: $@";}

$verbose = $opt->get_verbose ? $opt->get_verbose : VERBOSE;

# xmpp username/password to log in with
$username = $opt->get_username ? $opt->get_username : 'attacker';
$password = $opt->get_password ? $opt->get_password : 'attacker';
$domain = $opt->get_domain ? $opt->get_domain : 'example.com';
$host = $opt->get_host ? $opt->get_host : 'example.com';
$poe_td = $opt->get_poe_debug;
$poe_te = $opt->get_poe_event;

sub POE::Kernel::TRACE_DEFAULT  () { $poe_td }
sub POE::Kernel::TRACE_EVENTS  () { $poe_te }
use POE;
use Agent::TCLI::Transport::XMPP;
use Agent::TCLI::User;
use Agent::TCLI::Package::XMPP;
use Agent::TCLI::Package::Net::HTTP;
use Agent::TCLI::Package::Net::Ping;
use Agent::TCLI::Package::Net::Traceroute;
use Agent::TCLI::Package::Tail;

my $alias = 'net.agent';

#my @commands = (
#);

my @packages = (
	Agent::TCLI::Package::Net::HTTP->new(
	     'verbose'    => $verbose ,
	),
	Agent::TCLI::Package::Net::Ping->new(
	     'verbose'    => $verbose ,
	),
	Agent::TCLI::Package::Net::Traceroute->new(
	     'verbose'    => $verbose ,
	),
	Agent::TCLI::Package::Tail->new(
	     'verbose'    => $verbose ,
	),
	Agent::TCLI::Package::XMPP->new(
	     'verbose'    => $verbose ,
	),
);

my @users = (
	# If attacker is to be direcetded by user target, then target has to be a user.
	Agent::TCLI::User->new(
		'id'		=> 'target@'.$domain,
		'protocol'	=> 'xmpp',
		'auth'		=> 'master',
	),
	Agent::TCLI::User->new(
		'id'		=> 'user1@'.$domain,
		'protocol'	=> 'xmpp',
		'auth'		=> 'master',
	),
	Agent::TCLI::User->new(
		'id'		=> 'user2@'.$domain,
		'protocol'	=> 'xmpp',
		'auth'		=> 'master',
	),
	Agent::TCLI::User->new(
		'id'		=> 'conference_room@conference'.$doamin,
		'protocol'	=> 'xmpp_groupchat',
		'auth'		=> 'master',
	),
);

Agent::TCLI::Transport::XMPP->new(
     'jid'		=> Net::XMPP::JID->new($username.'@'.$domain.'/tcli'),
     'jserver'	=> $host,
	 'jpassword'=> $password,
	 'peers'	=> \@users,

	 'xmpp_debug' 		=> $opt->get_xmpp_debug,
	 'xmpp_process_time'=> 1,

     'verbose'    => $verbose,        # Verbose sets level or warnings

     'control_options'	=> {
	     'packages' 	=> \@packages,

     },
);
print "Starting ".$alias unless $verbose;

POE::Kernel->run();

print" FINISHED";

exit;

