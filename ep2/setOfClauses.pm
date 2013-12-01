#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

package setOfClauses;

sub new{
	my $class = shift;
	my $self = {
		variables => {},
		setOfClauses => [],
		instantiatedClauses => {}
	};
	bless $self, $class;
	return $self;
}

sub addPredicateList{
	my $self = shift;
	my $predicates = shift;
	my $restritors = shift;
	my $newCell = [$predicates,$restritors];
	push ($self->{setOfClauses},$newCell);	
}

sub addVariables{
	my $self = shift;
	my $key = shift;
	my $range = shift;
	$self->{variables}->{$key} = $range;
}

sub returnRange{
	my $self = shift;
	my $key = shift;
	my $range = $self->{variables}->{$key};
	return $range;
}

sub writeClauses{
	my $self = shift;
	for (my $x = 0; $x < $self->clausesListSize(); $x++) {
		my $clausuresList = $self->takeClausureList($x);
		my $predicate = takePredicateList($clausuresList);
		my $restritor = takeRestritorList($clausuresList);

		if ($restritor->[0] eq "null"){
			$self->writingPredicatesNotLimited($predicate);
		}
		else{
		}
	}
}
sub getZeroVector{
	my $size = shift;
	my @vector;
	for (my $x = 0; $x < $size; $x++) {
		$vector[$x] = 0;
	}
	return @vector;
}

sub changePredicate{
	my $string = shift;
	my $variable = shift;
	my $value = shift;
	my $newString = $string =~ s/$variable([,|\)])/$value$1/g;
	return $string;
}

# $inst = writePredicate($clause, \@variablesList, \@mergedVector);
sub writePredicate{
	my $clause = shift;
	my $variablesList = shift;
	my $mergedVector = shift;
	my $str = $clause;

	for (my $x = 0; $x < @$variablesList; $x++) {
		$str = changePredicate($str,@$variablesList[$x],@$mergedVector[$x]);
	}
	return $str;
}
sub writingPredicatesNotLimited{

	my $self = shift;
	my $predicate = shift;
	
	my $searchLvl;
	my $instance ;
	my $decision;
	my $pointer = 0;
	
	my @variablesList = returnVariablesList($predicate);
	my $size = @variablesList;
	my @vec = getZeroVector($size);
	
	my @lowRange = map { $self->getMinimumRange($_) } @variablesList;
	my @highRange = map { $self->getMaximumRange($_) } @variablesList;
	my $clause = returnFullClause($predicate);

	while(1){
		while(1) {
			my @tempVector = mergeVectors(\@vec,\@lowRange);
			$instance = writePredicate($clause, \@variablesList, \@tempVector);
			$self->{instantiatedClauses}->{$instance} = 1;
			if(!incrementVector(\@vec,\@lowRange,\@highRange,0)){ last; }
		}
		$decision = askIfPossible(\@vec,\@lowRange,\@highRange,$pointer);
		if($decision > -1){
			$searchLvl = $decision;
		}
		else{ 
			$searchLvl = askIfPossible(\@vec,\@lowRange,\@highRange,$pointer++); 
		}
		if ($searchLvl > -1){
			incrementVector(\@vec,\@lowRange,\@highRange,$searchLvl);
			resetSubGroups(\@vec,$searchLvl);
		}
		else{ last; }
	}
		
}

# resetSubGroups(\@vec,$searchLvl);
sub resetSubGroups{
	my $vector = shift;
	my $limit = shift;
	for (my $x = 0; $x < $limit; $x++) {
		@$vector[$x] = 0;
	}
}

sub mergeVectors{
	my $vector1 = shift;
	my $vector2 = shift;
	my $size = listSize($vector1);
	my @newVector;
	for (my $x = 0; $x < $size; $x++) {
		$newVector[$x] = @$vector1[$x] + @$vector2[$x];
	}
	return @newVector;
}
sub askIfPossible{
	my $vector = shift;
	my $lowRange = shift;
	my $highRange = shift;
	my $indx = shift;
	my $size = listSize($vector);
	if ($indx < $size){
		my $temp = @$vector[$indx] + @$lowRange[$indx];
		if($temp < @$highRange[$indx]){
			return $indx;
		}
		else{
			askIfPossible($vector,$lowRange,$highRange,++$indx);
		}
	}
	else{
		return -1;
	}
}

# incrementVector(\@vec,0); Forma de chamar!
sub incrementVector{
	my $vector = shift;
	my $lowRange = shift;
	my $highRange = shift;
	my $size = listSize($vector);
	my $indx = shift;


	if ($indx < $size){
		my $temp = @$vector[$indx] + @$lowRange[$indx];
		if($temp < @$highRange[$indx]){
			@$vector[$indx]++;
			return 1;
		}
		else{
			return 0;
		}
	}
	return 0;
}

sub getMinimumRange{
	my $self = shift;
	my $key = shift;
	return $self->{variables}->{$key}->[0];
}

sub getMaximumRange{
	my $self = shift;
	my $key = shift;
	return $self->{variables}->{$key}->[1];
}
sub returnFullClause{
	my $predicate = shift;
	my $str = "";
	my %hash;
	for (my $x = 0; $x < listSize($predicate); $x++) {
		$str = $str . " " . $predicate->[$x];
	}
	$str = $str . ".";
	return  $str;
	
}
sub returnVariablesList{
	my $predicate = shift;
	my $str = "";
	my %hash;
	for (my $x = 0; $x < listSize($predicate); $x++) {
		$str = $str . " " . $predicate->[$x];
	}
	while ($str =~ /([A-Z]+)/g){
		$hash{$1} = 1;
	}
	my @variables = $str =~ /([A-Z]+)/g;
	my @keyList = keys %hash;
	return  @keyList;
	 
}

sub printingPredicatesNotLimited{
	my $self = shift;
	my $predicate = shift;
	print ">"x30 ."\n";
	for (my $x = 0; $x < listSize($predicate); $x++) {
		print "#$x -- $predicate->[$x] \n";
	}
	print "<"x30 ."\n";
}

sub printClausesList{
	my $self = shift;
	for(my $x = 0; $x < $self->clausesListSize; $x++){
		my $clausuresList =  $self->takeClausureList($x);
		print "--------------------- \n";
		my $predicate = takePredicateList($clausuresList);
		for (my $y = 0; $y < listSize($predicate); $y++){
			print "$y - Predicado : $predicate->[$y]\n";
		}
		print "<=================================================> \n";
		my $restritor = takeRestritorList($clausuresList);
		for (my $y = 0; $y < listSize($restritor); $y++){
			print "$y - Restritor : $restritor->[$y]\n";
		}
		print "--------------------- \n";
	}
}	

sub takeClausureList{
	my $self = shift;
	my $index = shift;
	return $self->{setOfClauses}->[$index];
}

sub takePredicateList{
	my $list = shift;
	return $list->[0];
}

sub takeRestritorList{
	my $list = shift;
	return $list->[1];
}

sub printVariablesList{
	my $self = shift;
	my $hash = $self->{variables};
	my @keyList = keys $self->{variables};
	foreach my $a (@keyList){
			my $range = $self->takeTheRange($a);
			print "key : $a  \n";
			print "[$range->[0], $range->[1]] \n"
		}
	
}

sub takeTheRange{
	my $self = shift;
	my $key = shift;
	return $self->{variables}->{$key};
}
sub predicatesQuantites{
	my $self = shift;
	my $index = shift;
	my $quantitie;
	if (exists $self->{setOfClauses}->[$index]){
		$quantitie = listSize($self->{setOfClauses}->[$index]->[0]);
	}
	else{
		return 0;
	}
	return $quantitie;
}

sub clausesListSize{
	my $self = shift;
	my $s = $self->{setOfClauses};
	$s = @$s;
	return $s;
}

sub listSize{
	my $list = shift;
	$list = @$list;
	return $list
}

sub showInstances{
	my $self = shift;
	my @instances = sort keys $self->{instantiatedClauses};
	
	print "><" x 30 . "\n";
	foreach my $x (@instances) {
		print "$x \n";
	}
	print "><" x 30 . "\n";
}
1;

# foreach my $a (@$predicates){ print "$a << \n";}
#forma correta de iterar ao longo da lista