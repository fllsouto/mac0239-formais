#!/usr/bin/perl

use v5.10;
use FileHandle;
use strict;
use warnings;
use setOfClauses;

if (@ARGV < 1){	die "Falta arquivo de entrada!"}
my $input = $ARGV[0];
my $handle = FileHandle->new;
$handle->open("<$input");

my %variables;
my %sentences;

my $objeto = new setOfClauses();
while (my $line = <$handle>){
    given($line){
    	# print $line."\n";
	when($line =~ /^([A-Z]+):\s([0-9]+)\s([0-9]+).$/){
	    my $variavelCapturada = $1; #identifica o nome da variavel
	    my $rangeList = [$2, $3]; #cria uma (referencia para) lista com o range da variavel
	    $variables{$variavelCapturada} = $rangeList; #associa a variavel a seu range
	    # print "----Variavel----\n";
	    # print "Texto :" .$line ."\n";
	    # print "Variavel : $1\n";
	    # print "Range : ($2 ~ $3)\n";
	    # print "-----------------\n";	
	}

	# when($line =~ /^(-?[a-z]+[\(]([A-Z]+)(,\s*([A-Z]+))*?[\)]\s*)+.((\s([A-Z]+)(\s(\+|\-|\*|\/)\s[A-Z]+)*\s(<|>|>=|<=|==|!=)\s([A-Z]+)(\s(\+|\-|\*|\/)\s[A-Z]+)*)*[\.])?$/){

	when($line =~ /^(-?[a-z]+[\(]([A-Z]+)(,\s*([A-Z]+))*[\)]\s?)+.((\s([A-Z]+)(\s(\+|\-|\*|\/)\s[A-Z]+)*\s(<|>|>=|<=|==|!=)\s([A-Z]+)(\s(\+|\-|\*|\/)\s[A-Z]+)*)*[\.])?$/){
	    my @predicates = $line =~ /(-?[a-z]+[(][A-Z,\s]+[)])+\s?/g;
	    print "Eis o role: @predicates\n";
	    my $predicatesList = [@predicates];
	    my @restritores = $line =~ /((\s([A-Z]+)(\s(\+|\-|\*|\/)\s[A-Z]+)*\s(<|>|>=|<=|==|!=)\s([A-Z]+)(\s(\+|\-|\*|\/)\s[A-Z]+)*)*[\.])?/g;
	    print "OLHA AS RESTRICOES: @restritores\n\n";
	    my $restritoresList = [@restritores];
	    # print "HELLO\n  $predicatesList->[1] \n #########";
	    # foreach $a (@listall){ print "$a >>\n";}
	    # my $s = @listall;
	    # print "Before size $s\n";
	    $objeto->addPredicateList($predicatesList,$restritoresList);
	    
	}
	# #when($line =~/^[\.]((\s([A-Z]+)(\s(\+|\-|\*|\/)\s[A-Z]+)*\s(<|>|>=|<=|==|!=)\s([A-Z]+)(\s(\+|\-|\*|\/)\s[A-Z]+)*)*[\.])?$/){
	default{
	    print "----ERRO----\n";
	    print "Texto :" .$line ."\n";
	    print "-----------------\n";	
	}
    }
}

#$objeto->printPredicateList();

$handle->close;

