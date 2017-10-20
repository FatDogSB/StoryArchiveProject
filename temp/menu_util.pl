#!/home/aruba/bin/gnu/isqlperl
# use Test::Harness;
# use DB_File;
# use strict 'untie';
# Initial revision
#
#

&main ();
exit (0);

#-------------------------------------------------------------------------
# PrintMenu2 - Prints the menu
#-------------------------------------------------------------------------
sub PrintMenu2 {

    print "=============================================\n";
    print "              Main Menu\n";
    print "             HTML Utilitys\n";
    print "=============================================\n";
    print "Please choose an option:\n\n";
    print "\t1 - \n";
    print "\t2 - \n";
    print "\t3 - \n";
    print "\t4 - \n";
    print "\t5 - \n";
    print "\t6 - \n";
    print "\t7 - \n";
    print "\t8 - \n";
    print "\t9 - \n";
    print "\n\n";
    print "\t\tChoice: ";

}  # PrintMenu2

#-------------------------------------------------------------------------
# Menu - Provides a menu for choices.  Returns the choice number.
#  If the choice requires a path, this routine will ask for it and
#  error check the path before returning.  The path will be stored
#  in $g_Path;
#-------------------------------------------------------------------------
sub GetChoice {

    local ($l_finished) = 0;
    local ($l_choice) = 0;

    while ( $l_finished == 0) {
        &PrintMenu2 ();

        chop ($l_choice = <STDIN>);

        if ( ($l_choice > 0) && ($l_choice < 10) ) {
            $l_finished = 1;
        }
    }
    $l_choice;

} # GetChoice


#----------------------------------------------------------
#  Main
#----------------------------------------------------------
sub main {

	print "There are ($#ARGV) arguments\n";
	if ( $ARGV[0] != undef ) { print "Arg 1 = $ARGV[0]\n";}
	if ( $ARGV[1] != undef ) { print "Arg 2 = $ARGV[1]\n";}
	if ( $ARGV[2] != undef ) { print "Arg 3 = $ARGV[2]\n";}

	# &S_BreakFile2 ("s.txt");



#	while ( <> )
#	{
#		print "($_) \n";
#	}

    local ($l_finished) = 0;

    while ( ! $l_finished )
    {
        $g_choice = &GetChoice();

        if ( $g_choice == 1 )
        {
            $l_finished = 1;
        } elsif ( $g_choice == 2 ) {

            $l_finished = 1;
        } elsif ( $g_choice == 3 ) {
            $l_finished = 1;
        } elsif ( $g_choice == 4 ) {
            $l_finished = 1;
        } elsif ( $g_choice == 5 ) {
            $l_finished = 1;
        } elsif ( $g_choice == 6 ) {
            $l_finished = 1;
        } elsif ( $g_choice == 7 ) {
            $l_finished = 1;
        } elsif ( $g_choice == 8 ) {
            $l_finished = 1;
        } elsif ( $g_choice == 9 ) {
            $l_finished = 1;
        } else {
			$l_finished = 1;
		}
    }


}

# End of main
