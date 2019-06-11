#perl script to transform a "classic" TREC formatted topic file into one Indri can work with
#(tested for ROBUST04)

use strict;

my $numArgs = $#ARGV+ 1;
if($numArgs < 3 ){
    print "Three command line arguments expected: [input: TREC formatted topic file] [output: Indri formatted file] [part (title/desc/narr)]\n";
    exit;
}

my $infile = $ARGV[0]; #topic file in TREC format
my $outfile = $ARGV[1]; #topic file in Indri format
my $topicType = $ARGV[2]; #part of the topic file to consider (encompassing, i.e. choosing desc means title+desc)

if($topicType ne "title" && $topicType ne "desc" && $topicType ne "narr"){
    print "The last argument is one of title|desc|narr.\n";
    exit;
}

open(OUT,">>$outfile")||die $!;
print OUT "<parameters>\n";

my $inType = "";
open(IN,$infile)||die $!;
while(<IN>){
    chomp;
    if($_ =~m/<num>/){
        print OUT "<query>\n";
        print OUT "<number>";
        my $qid = $_;
        $_ =~s/.*Number\s*:\s*//;  
        $_ =~s/\s+//g;
        print OUT "$_</number>\n";
        print OUT "<text>#combine(";
    }
    elsif($_=~m/<top>/){;}
    elsif($_=~m/<\/top>/){
        print OUT ")</text>\n</query>\n";
        $inType = "";
    }
    elsif($_=~m/<title>/){
        #we always print the title
        $_=~s/<title>\s*//;
        print OUT "$_ ";
    }
    elsif($_=~m/<desc>/){
        $inType = "D";
    }
    elsif($_=~m/<narr>/){
        $inType = "N";
    }
    elsif($inType eq "D" && ($topicType eq "desc" || $topicType eq "narr")){
        print OUT "$_ ";
    }
    elsif($inType eq "N" && $topicType eq "narr"){
        print OUT "$_ ";
    }
}

print OUT "</parameters>\n";
close(OUT);
close(IN);
