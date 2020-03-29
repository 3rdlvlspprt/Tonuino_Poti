use strict;
use warnings;
use File::Find;
use File::Copy;
use MP3::Info;
use Getopt::Long;


print $0;
if( $0 =~ m/\.pl$/i) {
	print " run as interpreter\n";
}

my $source = "";
my $target = "";
my $help = 0;

  GetOptions ("quelle|source=s" => \$source,    # source folder
              "ziel|target=s" => \$target)    # target folder
			  '?|h|help=s' => \$help)    # target folder
  or print_usage();

  print_usage() if $help;
  
my $folderinfo;
my @file_list;
my $tag;

sub print_usage {
    printf "USAGE:\n";
	printf "\n";
	printf " copyfiles.pl -?|h|help\n");
	printf "\n";
    printf " copyfiles.pl -source \"c:\\mp3\\bibi und Tina\" -target g:\\02 \n";
	printf "  assumption: c:\\mp3\\ holds the mp3 files. g:\\ is hte SDcard folder.\n";
	printf "  checks if folder doesn't exist and start copy.\n";
	printf "\n";
    printf " copyfiles.pl -quelle \"c:\\mp3\\bibi und Tina\" -ziel g:\\02 \n";
	printf "  Annahme: c:\\mp3\\ ist das quellverzeichnisder mp3 dateien.\n";
    printf "           g:\\ ist das Hauptverzeichnis der SDkarte.\n";
	printf "  Das Programm prüft, ob das verzeichnis moch nicht existiert, und startet erst dann das Kopieren.\n";
    exit;
}
printf "read SOURCE folder '$source'\n";

if( -d $target){
	die "TARGET Folder '$target' exist, use next higher number";
}else{
	printf "create TARGET folder $target";
	mkdir $target;
}

find ( \&wanted, $source);

sub wanted {
    return unless -f;
    return unless /\.mp3$/;
    push @file_list, $File::Find::name;
}

@file_list = sort @file_list;

# At this point, @file_list contains all of the files I found.
print join("\n", @file_list) ;
print "\n"x2;

foreach my $f (@file_list){
	if( $f =~  m/[\\\/](\d+)[^\\\/]*\.mp3/ig ){
		my $num = $1;
		
		if( "" eq $folderinfo ){
			$tag = get_mp3tag($f);
			$folderinfo = join( "_", ($tag->{ARTIST}, $tag->{ALBUM}));
			printf $folderinfo;
		}
		
		my $tf = sprintf("$target/"."%03d\.mp3", $num);
		
		printf( "copy $f  -> $tf \n");
		copy( $f, $tf ) or warn "Copy failed: $!";
	}else{
		printf( "unmatched copy $f \n" );
	
	}
}

if( "" ne $folderinfo ){
	my $filename = sprintf("$target/$folderinfo\.txt");
	my $fh;
	open($fh, '>', $filename ) or print "Unable to open file $filename : $!";
	print $fh join("\n", @file_list);
	close($fh);
}
		


