#!/usr/bin/perl
#
# Simple log/alarm server receiving and printing to console remote dvr/camera events. Tested with:
#
# HJCCTV HJ-H4808BW
# http://www.aliexpress.com/item/Hybird-NVR-8chs-H-264DVR-8chs-onvif-2-3-Economical-DVR-8ch-Video-4-AUDIO-AND/1918734952.html
#
# PBFZ TCV-UTH200
# http://www.aliexpress.com/item/Free-shipping-2014-NEW-IP-camera-CCTV-2-0MP-HD-1080P-IP-Network-Security-CCTV-Waterproof/1958962188.html

use IO::Socket;
use IO::Socket::INET;
use Sys::Syslog;
use Sys::Syslog qw(:DEFAULT setlogsock);
use Sys::Syslog qw(:standard :macros);
use Time::Local;
use JSON;
use Data::Dumper;
use Net::MQTT::Simple;

setlogsock("console");
openlog("dvr-alarm-server", "cons,pid", LOG_USER);
$ENV{PATH} = '/bin:/usr/bin';
$ENV{SHELL} = '/bin/sh' if exists $ENV{SHELL};
delete @ENV{qw(IFS CDPATH ENV BASH_ENV)};

sub BuildPacket {
 my ($type, $params) = ($_[0], $_[1]);
 my @pkt_prefix_1;
 my @pkt_prefix_2;
 my @pkt_type;
 my $sid = 0;
 my $json = JSON->new;
 
 @pkt_prefix_1 = (0xff, 0x00, 0x00, 0x00);
 @pkt_prefix_2 =  (0x00, 0x00, 0x00, 0x00); 
 
 if ($type eq 'login') {
   @pkt_type = (0x00, 0x00, 0xe8, 0x03);
 } elsif ($type eq 'info') {
   @pkt_type = (0x00, 0x00, 0xfc, 0x03);
 }
 
 $sid = hex($params->{'SessionID'});
 
 my $pkt_prefix_data =  pack('c*', @pkt_prefix_1) . pack('i', $sid) . pack('c*', @pkt_prefix_2). pack('c*', @pkt_type);
 my $pkt_params_data =  $json->encode($params);
 my $pkt_data = $pkt_prefix_data . pack('i', length($pkt_params_data)) . $pkt_params_data;
 
 return $pkt_data;
}

sub GetConfig {
 my $filename = 'config/config.json';
 my $value = $_[0];
 my $json_text = do {
   open(my $json_fh, "<:encoding(UTF-8)", $filename)
      or die("Can't open \"$filename\": $!\n");
   local $/;
   <$json_fh>
 };
 
 my $arrayref = decode_json $json_text;
 #print Dumper $arrayref;
 foreach my $item( @$arrayref ) { 
    return $item->{$value};
 }
}

sub GetReplyHead {
 my $sock = $_[0];
 my @reply_head_array;

 for (my $i = 0; $i < 4; $i++) {
  $sock->recv($data, 4);
  $reply_head[$i]  = unpack('i', $data);
  #write_log("reply data: '$data' replyhead: " . $reply_head[$i] . " ");
  #print "$i: " . $reply_head[$i] . "\n";
 }
 
 my $reply_head = {
  Prefix1 => $reply_head[0],
  Prefix2 => $reply_head[1],
  Prefix3 => $reply_head[2],
  Content_Length => $reply_head[3]
 };
 
 return $reply_head;
}

my $sock = new IO::Socket::INET ( LocalHost => '0.0.0.0', LocalPort => '15002', Proto => 'tcp',  Listen => 1, Reuse => 1 ); die "Could not create socket: $!\n" unless $sock;
write_log("Socket create in port 15002");
mqtt("test","ON");

while (my ($client,$clientaddr) = $sock->accept()) {
 #write_log("Connected from ".$client->peerhost());
 $pid = fork();
 die "Cannot fork: $!" unless defined($pid);
 if ($pid == 0) { 
     #write_log("pid is 0");
     # Child process
     my $data = '';
     $client->recv($data, 4);
     if ($data eq "GET ") {
       $client->recv($data, 70);
       #write_log("data: '$data'");
     }
     else {
       my $reply = GetReplyHead($client);
       # Client protocol detection
       $client->recv($data, $reply->{'Content_Length'});
     }
     write_log("Connected from ".$client->peerhost()." data: '$data'");
     #print Dumper decode_json($data);
     my $cproto = $data;
     #write_log("Connected from ".$client->peerhost() . " proto = '$cproto'");
     # if (index($cproto, "Start") != -1) {
		#   mqtt($client->peerhost(), "ON");
     # }
     if (index($cproto, "Stop") == -1) {
       mqtt($client->peerhost(), "ON");
     }
     exit(0);   # Child process exits when it is done.
 } # else 'tis the parent process, which goes back to accept()
}
close($sock);

sub mqtt() {
 $ENV{MQTT_SIMPLE_ALLOW_INSECURE_LOGIN} = 'true';
 my $mqttserver = GetConfig("MQTTserver");
 my $mqttuser = GetConfig("MQTTuser");
 my $mqttpass = GetConfig("MQTTpass");
 my $mqtt = Net::MQTT::Simple->new($mqttserver);
 $mqtt->login($mqttuser,$mqttpass);
 $mqtt->retain("home-assistant/" . $_[0] ."/movimiento" => $_[1]);
 $mqtt->disconnect();
 write_log("Mqtt user ".$mqttuser." message send home-assistant/" . $_[0] ."/movimiento => ". $_[1]);
}

sub write_log() {
 #syslog('info', $_[0]);
 my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time());
 my $timestamp = sprintf("%02d.%02d.%4d %02d:%02d:%02d",$mday,$mon+1,$year+1900,$hour,$min,$sec);
 print "$timestamp dvr-alarm-server[] " . $_[0] ."\n";
}
