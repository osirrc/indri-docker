#TREC topics (tested on Robust04 topics) converted to Indri's file format.
#TODO: instead of manual XML parsing, use a library.

use strict;

#takes a string and cleans it up
sub clean { 
    my $s = shift; 
    $s  =~ s/[^a-zA-Z0-9]/ /g;  
    $s = lc($s);  
    return $s; 
}

my $numArgs = $#ARGV+ 1;
if($numArgs < 4 ){
    print "Four command line arguments expected: [input: TREC formatted topic file] [output: Indri formatted file] [part (title/desc/narr)] [retrieval rule]\n";
    exit;
}

my $infile = $ARGV[0]; #topic file in TREC format
my $outfile = $ARGV[1]; #topic file in Indri format
my $topicType = $ARGV[2]; #part of the topic file to consider (encompassing, i.e. choosing desc means title+desc)
my $retrievalRule = $ARGV[3]; #retrieval rule

if($topicType ne "title" && $topicType ne "desc" && $topicType ne "narr"){
    print "The last argument (now: $topicType) is one of title|desc|narr.\n";
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

        print OUT "<text>";
        if($retrievalRule=~m/(okapi|tfidf)/){
            ;
        }
        else {
            print OUT "#combine(";
        }
    }
    elsif($_=~m/<top>/){;}
    elsif($_=~m/<\/top>/){
        if($retrievalRule=~m/(okapi|tfidf)/){
            ;
        }
        else {
            print OUT ")";
        }
        print OUT "</text>\n</query>\n";
        $inType = "";
    }
    elsif($_=~m/<title>/){
        #we always print the title
        $_=~s/<title>\s*//;
        print OUT clean($_)." ";
        $inType = "T";
    }
    elsif($_=~m/<desc>/){
        $inType = "D";
    }
    elsif($_=~m/<narr>/){
        $inType = "N";
    }
    elsif($inType eq "T"){
        print OUT clean($_)." ";
    }
    elsif($inType eq "D" && ($topicType eq "desc" || $topicType eq "narr")){
        print OUT clean($_)." ";
    }
    elsif($inType eq "N" && $topicType eq "narr"){
        print OUT clean($_)." ";
    }
}

print OUT "</parameters>\n";
close(OUT);
close(IN);
