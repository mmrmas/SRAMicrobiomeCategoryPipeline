#!/usr/bin/perl -w
use strict;

##SUBS
sub makeFeature_sub{
  my $file = shift(@_);
  my $hshRef = shift(@_);
  my $category = shift(@_);
  open (F, $file) or die $!;

  #add category to the hash and check it's length
  push (@ { $hshRef->{'categories'} }, $category);
  my $elementsInHshs = scalar @{ $hshRef->{'categories'} };

  while (my $line = <F>){
    chomp $line;
    next if $line =~ /^\#/;
    next if $line =~ /^\s+$/;
    $line =~ s/\,\s+$//g;
    $line =~ s/[\{\}\}]//g;
    $line =~ s/\://g;
    my @lineArr = split(/\"/, $line);
    my $key = '';
    my $percentage = 0;
    for (my $i = 0; $i < scalar @lineArr; $i++){
      my $el = $lineArr[$i];
      $el =~ s/\s//g;
      $key =  $lineArr[$i+2]."\t" if $el eq 'name';
      $percentage =  $lineArr[$i+2]  if $el eq 'percent';
    }
    if ($percentage > 0){
      $key =~ s/\s+$//;
      $key =~ s/\s+/\_/g;
      $key =~ s/\,//g;
      if (defined $hshRef->{$key}){
        my $curLength = scalar @ { $hshRef->{$key} };
        for (my $i = $curLength; $i < $elementsInHshs-1; $i++){
            push (@ { $hshRef->{$key} }, 0);
        }
        push (@ { $hshRef->{$key} }, $percentage);
      }
      else{
        for (my $i = 0; $i < $elementsInHshs-1; $i++){
            push (@ { $hshRef->{$key} }, 0);
        }
        push (@ { $hshRef->{$key} }, $percentage);
      }
    }
  }

  #then fill the hash up to the longest array
  foreach my $key (keys %$hshRef){
    my $curLength = scalar @ { $hshRef -> {$key}};
    for (my $i = $curLength; $i < $elementsInHshs; $i++){
      push (@ { $hshRef->{$key} }, 0);
    }
  }


  close (F);
}


#by Sam 2021 September 18

my $indir         = '';
my $outFile       = '';

#get the assay data and the service data
if (scalar (@ARGV) == 0){
	warn "type: perl SRAFeatureTable.pl -i [input directory] -o [output file]\n";
	warn "this script is to process the output of scrapeSRA.py\n";
	warn "press ENTER to continue, add options if needed, or enter \"Q\" to exit\n";
	while (<>){
		chomp;
		exit if $_ eq 'Q';
		@ARGV = split(/\s+/,$_);
		last;
	}
}

while (@ARGV){
	my $el = shift @ARGV;
	$indir = shift @ARGV if ($el eq '-i');
	$outFile = shift @ARGV if ($el eq '-o');
}



#globals
my @categoryDirectories = ();
my %fullTable = ();


#get the directories and create the categories
opendir (DIR, $indir) or die $!;
while (my $categoryDir = readdir(DIR)) {
  next if $categoryDir =~ /^\./;
  push ( @categoryDirectories, $categoryDir,);
}
closedir(DIR);


#now read through every category directory; open each file; send content to makeNode_sub and store in a new filename
foreach my $dirname (@categoryDirectories){
  opendir(DIR, $indir.'/'. $dirname) or die $!;
  while (my $categoryFile = readdir(DIR)) {
    warn $categoryFile;
    next if $categoryFile =~ /^\./;
    my $toSub =  $indir.'/' . $dirname . '/' . $categoryFile;
    makeFeature_sub($toSub, \%fullTable, $dirname);
  }
  closedir(DIR);
}


open (O, '>'.$outFile);
my @columns = keys (%fullTable);
my $rowlengts = scalar @{ $fullTable{'categories'}};
print O (join("\,", @columns));
print O "\n";
for (my $i = 0; $i < $rowlengts ; $i++){
  my $j = 0;
  foreach my $column (@columns){
    print O $fullTable{$column}->[$i] if $j == 0;
    print O "\,", $fullTable{$column}->[$i] if $j != 0;
    $j++;
  }
  print O "\n";
}
