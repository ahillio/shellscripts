#!/usr/bin/env perl
#
# This file, ack, is generated code.
# Please DO NOT EDIT or send patches for it.
#
# Please take a look at the source from
# https://github.com/beyondgrep/ack3
# and submit patches against the individual files
# that build ack.
#

$App::Ack::STANDALONE = 1;
package main;

use strict;
use warnings;

our $VERSION = 'v3.4.0'; # Check https://beyondgrep.com/ for updates

use 5.010001;

use File::Spec ();



# Global command-line options
our $opt_1;
our $opt_A;
our $opt_B;
our $opt_break;
our $opt_color;
our $opt_column;
our $opt_debug;
our $opt_c;
our $opt_f;
our $opt_g;
our $opt_heading;
our $opt_L;
our $opt_l;
our $opt_m;
our $opt_output;
our $opt_passthru;
our $opt_p;
our $opt_range_start;
our $opt_range_end;
our $opt_range_invert;
our $opt_regex;
our $opt_show_filename;
our $opt_show_types;
our $opt_underline;
our $opt_v;

# Flag if we need any context tracking.
our $is_tracking_context;

# The regex that we search for in each file.
our $search_re;

# Special /m version of our $search_re.
our $scan_re;

our @special_vars_used_by_opt_output;

our $using_ranges;

# Internal stats for debugging.
our %stats;

MAIN: {
    $App::Ack::ORIGINAL_PROGRAM_NAME = $0;
    $0 = join(' ', 'ack', $0);
    $App::Ack::ors = "\n";
    if ( $App::Ack::VERSION ne $main::VERSION ) {
        App::Ack::die( "Program/library version mismatch\n\t$0 is $main::VERSION\n\t$INC{'App/Ack.pm'} is $App::Ack::VERSION" );
    }

    # Do preliminary arg checking;
    my $env_is_usable = 1;
    for my $arg ( @ARGV ) {
        last if ( $arg eq '--' );

        # Get the --thpppt, --bar, --cathy and --man checking out of the way.
        $arg =~ /^--th[pt]+t+$/ and App::Ack::thpppt($arg);
        $arg eq '--bar'         and App::Ack::ackbar();
        $arg eq '--cathy'       and App::Ack::cathy();

        # See if we want to ignore the environment. (Don't tell Al Gore.)
        $arg eq '--env'         and $env_is_usable = 1;
        $arg eq '--noenv'       and $env_is_usable = 0;
    }

    if ( $env_is_usable ) {
        if ( $ENV{ACK_OPTIONS} ) {
            App::Ack::warn( 'WARNING: ack no longer uses the ACK_OPTIONS environment variable.  Use an ackrc file instead.' );
        }
    }
    else {
        my @keys = ( 'ACKRC', grep { /^ACK_/ } keys %ENV );
        delete @ENV{@keys};
    }

    # Load colors
    my $modules_loaded_ok = eval 'use Term::ANSIColor 1.10 (); 1;';
    if ( $modules_loaded_ok && $App::Ack::is_windows ) {
        $modules_loaded_ok = eval 'use Win32::Console::ANSI; 1;';
    }
    if ( $modules_loaded_ok ) {
        $ENV{ACK_COLOR_MATCH}    ||= 'black on_yellow';
        $ENV{ACK_COLOR_FILENAME} ||= 'bold green';
        $ENV{ACK_COLOR_LINENO}   ||= 'bold yellow';
        $ENV{ACK_COLOR_COLNO}    ||= 'bold yellow';
    }

    my $p = App::Ack::ConfigLoader::opt_parser( 'no_auto_abbrev', 'pass_through' );
    $p->getoptions(
        help     => sub { App::Ack::show_help(); exit; },
        version  => sub { App::Ack::print( App::Ack::get_version_statement() ); exit; },
        man      => sub { App::Ack::show_man(); },
    );

    if ( !@ARGV ) {
        App::Ack::show_help();
        exit 1;
    }

    my @arg_sources = App::Ack::ConfigLoader::retrieve_arg_sources();

    my $opt = App::Ack::ConfigLoader::process_args( @arg_sources );

    $opt_1              = $opt->{1};
    $opt_A              = $opt->{A};
    $opt_B              = $opt->{B};
    $opt_break          = $opt->{break};
    $opt_c              = $opt->{c};
    $opt_color          = $opt->{color};
    $opt_column         = $opt->{column};
    $opt_debug          = $opt->{debug};
    $opt_f              = $opt->{f};
    $opt_g              = $opt->{g};
    $opt_heading        = $opt->{heading};
    $opt_L              = $opt->{L};
    $opt_l              = $opt->{l};
    $opt_m              = $opt->{m};
    $opt_output         = $opt->{output};
    $opt_p              = $opt->{p};
    $opt_passthru       = $opt->{passthru};
    $opt_range_start    = $opt->{range_start};
    $opt_range_end      = $opt->{range_end};
    $opt_range_invert   = $opt->{range_invert};
    $opt_regex          = $opt->{regex};
    $opt_show_filename  = $opt->{show_filename};
    $opt_show_types     = $opt->{show_types};
    $opt_underline      = $opt->{underline};
    $opt_v              = $opt->{v};

    if ( $opt_show_types && not( $opt_f || $opt_g ) ) {
        App::Ack::die( '--show-types can only be used with -f or -g.' );
    }

    if ( $opt_range_start ) {
        ($opt_range_start, undef) = build_regex( $opt_range_start, {} );
    }
    if ( $opt_range_end ) {
        ($opt_range_end, undef)   = build_regex( $opt_range_end, {} );
    }
    $using_ranges = $opt_range_start || $opt_range_end;

    $App::Ack::report_bad_filenames = !$opt->{s};
    $App::Ack::ors = $opt->{print0} ? "\0" : "\n";

    if ( !defined($opt_color) && !$opt_g ) {
        my $windows_color = 1;
        if ( $App::Ack::is_windows ) {
            $windows_color = eval { require Win32::Console::ANSI; };
        }
        $opt_color = !App::Ack::output_to_pipe() && $windows_color;
    }
    $opt_heading //= !App::Ack::output_to_pipe();
    $opt_break //= !App::Ack::output_to_pipe();

    if ( defined($opt->{H}) || defined($opt->{h}) ) {
        $opt_show_filename = $opt->{show_filename} = $opt->{H} && !$opt->{h};
    }

    if ( defined $opt_output ) {
        # Expand out \t, \n and \r.
        $opt_output =~ s/\\n/\n/g;
        $opt_output =~ s/\\r/\r/g;
        $opt_output =~ s/\\t/\t/g;

        my @supported_special_variables = ( 1..9, qw( _ . ` & ' +  f ) );
        @special_vars_used_by_opt_output = grep { $opt_output =~ /\$$_/ } @supported_special_variables;

        # If the $opt_output contains $&, $` or $', those vars won't be
        # captured until they're used at least once in the program.
        # Do the eval to make this happen.
        for my $i ( @special_vars_used_by_opt_output ) {
            if ( $i eq q{&} || $i eq q{'} || $i eq q{`} ) {
                no warnings;    # They will be undef, so don't warn.
                eval qq{"\$$i"};
            }
        }
    }

    # Set up file filters.
    my $files;
    if ( $App::Ack::is_filter_mode && !$opt->{files_from} ) { # probably -x
        $files     = App::Ack::Files->from_stdin();
        $opt_regex //= shift @ARGV;
        ($search_re, $scan_re) = build_regex( $opt_regex, $opt );
        $stats{search_re} = $search_re;
        $stats{scan_re} = $scan_re;
    }
    else {
        if ( $opt_f ) {
            # No need to check for regex, since mutex options are handled elsewhere.
        }
        else {
            $opt_regex //= shift @ARGV;
            ($search_re, $scan_re) = build_regex( $opt_regex, $opt );
            $stats{search_re} = $search_re;
            $stats{scan_re} = $scan_re;
        }
        # XXX What is this checking for?
        if ( $search_re && $search_re =~ /\n/ ) {
            App::Ack::exit_from_ack( 0 );
        }
        my @start;
        if ( not defined $opt->{files_from} ) {
            @start = @ARGV;
        }
        if ( !exists($opt->{show_filename}) ) {
            unless(@start == 1 && !(-d $start[0])) {
                $opt_show_filename = $opt->{show_filename} = 1;
            }
        }

        if ( defined $opt->{files_from} ) {
            $files = App::Ack::Files->from_file( $opt, $opt->{files_from} );
            exit 1 unless $files;
        }
        else {
            @start = ('.') unless @start;
            foreach my $target (@start) {
                if ( !-e $target && $App::Ack::report_bad_filenames) {
                    App::Ack::warn( "$target: No such file or directory" );
                }
            }

            $opt->{file_filter}    = _compile_file_filter($opt, \@start);
            $opt->{descend_filter} = _compile_descend_filter($opt);

            $files = App::Ack::Files->from_argv( $opt, \@start );
        }
    }
    App::Ack::set_up_pager( $opt->{pager} ) if defined $opt->{pager};

    my $nmatches;
    if ( $opt_f || $opt_g ) {
        $nmatches = file_loop_fg( $files );
    }
    elsif ( $opt_c ) {
        $nmatches = file_loop_c( $files );
    }
    elsif ( $opt_l || $opt_L ) {
        $nmatches = file_loop_lL( $files );
    }
    else {
        $nmatches = file_loop_normal( $files );
    }

    if ( $opt_debug ) {
        require List::Util;
        my @stats = qw( search_re scan_re prescans linescans filematches linematches );
        my $width = List::Util::max( map { length } @stats );

        for my $stat ( @stats ) {
            App::Ack::warn( sprintf( '%-*.*s = %s', $width, $width, $stat, $stats{$stat} // 'undef' ) );
        }
    }

    close $App::Ack::fh;

    App::Ack::exit_from_ack( $nmatches );
}

# End of MAIN

sub file_loop_fg {
    my $files = shift;

    my $nmatches = 0;
    while ( defined( my $file = $files->next ) ) {
        if ( $opt_show_types ) {
            App::Ack::show_types( $file );
        }
        elsif ( $opt_g ) {
            print_line_with_options( undef, $file->name, 0, $App::Ack::ors );
        }
        else {
            App::Ack::say( $file->name );
        }
        ++$nmatches;
        last if defined($opt_m) && ($nmatches >= $opt_m);
    }

    return $nmatches;
}


sub file_loop_c {
    my $files = shift;

    my $total_count = 0;
    while ( defined( my $file = $files->next ) ) {
        my $matches_for_this_file = count_matches_in_file( $file );

        if ( not $opt_show_filename ) {
            $total_count += $matches_for_this_file;
            next;
        }

        if ( !$opt_l || $matches_for_this_file > 0 ) {
            if ( $opt_show_filename ) {
                my $display_filename = $file->name;
                if ( $opt_color ) {
                    $display_filename = Term::ANSIColor::colored($display_filename, $ENV{ACK_COLOR_FILENAME});
                }
                App::Ack::say( $display_filename, ':', $matches_for_this_file );
            }
            else {
                App::Ack::say( $matches_for_this_file );
            }
        }
    }

    if ( !$opt_show_filename ) {
        App::Ack::say( $total_count );
    }

    return;
}


sub file_loop_lL {
    my $files = shift;

    my $nmatches = 0;
    while ( defined( my $file = $files->next ) ) {
        my $is_match = count_matches_in_file( $file, 1 );

        if ( $opt_L ? !$is_match : $is_match ) {
            App::Ack::say( $file->name );
            ++$nmatches;

            last if $opt_1;
            last if defined($opt_m) && ($nmatches >= $opt_m);
        }
    }

    return $nmatches;
}


sub _compile_descend_filter {
    my ( $opt ) = @_;

    my $idirs = 0;
    my $dont_ignore_dirs = 0;

    for my $filter (@{$opt->{idirs} || []}) {
        if ($filter->is_inverted()) {
            $dont_ignore_dirs++;
        }
        else {
            $idirs++;
        }
    }

    # If we have one or more --noignore-dir directives, we can't ignore
    # entire subdirectory hierarchies, so we return an "accept all"
    # filter and scrutinize the files more in _compile_file_filter.
    return if $dont_ignore_dirs;
    return unless $idirs;

    $idirs = $opt->{idirs};

    return sub {
        my $file = App::Ack::File->new($File::Next::dir);
        return !grep { $_->filter($file) } @{$idirs};
    };
}

sub _compile_file_filter {
    my ( $opt, $start ) = @_;

    my $ifiles_filters = $opt->{ifiles};

    my $filters         = $opt->{'filters'} || [];
    my $direct_filters = App::Ack::Filter::Collection->new();
    my $inverse_filters = App::Ack::Filter::Collection->new();

    foreach my $filter (@{$filters}) {
        if ($filter->is_inverted()) {
            # We want to check if files match the uninverted filters
            $inverse_filters->add($filter->invert());
        }
        else {
            $direct_filters->add($filter);
        }
    }

    my %is_member_of_starting_set = map { (get_file_id($_) => 1) } @{$start};

    my @ignore_dir_filter = @{$opt->{idirs} || []};
    my @is_inverted       = map { $_->is_inverted() } @ignore_dir_filter;
    # This depends on InverseFilter->invert returning the original filter (for optimization).
    @ignore_dir_filter         = map { $_->is_inverted() ? $_->invert() : $_ } @ignore_dir_filter;
    my $dont_ignore_dir_filter = grep { $_ } @is_inverted;
    my $previous_dir = '';
    my $previous_dir_ignore_result;

    return sub {
        if ( $opt_g ) {
            if ( $File::Next::name =~ /$search_re/o ) {
                return 0 if $opt_v;
            }
            else {
                return 0 if !$opt_v;
            }
        }
        # ack always selects files that are specified on the command
        # line, regardless of filetype.  If you want to ack a JPEG,
        # and say "ack foo whatever.jpg" it will do it for you.
        return 1 if $is_member_of_starting_set{ get_file_id($File::Next::name) };

        if ( $dont_ignore_dir_filter ) {
            if ( $previous_dir eq $File::Next::dir ) {
                if ( $previous_dir_ignore_result ) {
                    return 0;
                }
            }
            else {
                my @dirs = File::Spec->splitdir($File::Next::dir);

                my $is_ignoring = 0;

                for ( my $i = 0; $i < @dirs; $i++) {
                    my $dir_rsrc = App::Ack::File->new(File::Spec->catfile(@dirs[0 .. $i]));

                    my $j = 0;
                    for my $filter (@ignore_dir_filter) {
                        if ( $filter->filter($dir_rsrc) ) {
                            $is_ignoring = !$is_inverted[$j];
                        }
                        $j++;
                    }
                }

                $previous_dir               = $File::Next::dir;
                $previous_dir_ignore_result = $is_ignoring;

                if ( $is_ignoring ) {
                    return 0;
                }
            }
        }

        # Ignore named pipes found in directory searching.  Named
        # pipes created by subprocesses get specified on the command
        # line, so the rule of "always select whatever is on the
        # command line" wins.
        return 0 if -p $File::Next::name;

        # We can't handle unreadable filenames; report them.
        if ( not -r _ ) {
            use filetest 'access';

            if ( not -R $File::Next::name ) {
                if ( $App::Ack::report_bad_filenames ) {
                    App::Ack::warn( "${File::Next::name}: cannot open file for reading" );
                }
                return 0;
            }
        }

        my $file = App::Ack::File->new($File::Next::name);

        if ( $ifiles_filters && $ifiles_filters->filter($file) ) {
            return 0;
        }

        my $match_found = $direct_filters->filter($file);

        # Don't bother invoking inverse filters unless we consider the current file a match.
        if ( $match_found && $inverse_filters->filter( $file ) ) {
            $match_found = 0;
        }
        return $match_found;
    };
}


# Returns a (fairly) unique identifier for a file.
# Use this function to compare two files to see if they're
# equal (ie. the same file, but with a different path/links/etc).
sub get_file_id {
    my ( $filename ) = @_;

    if ( $App::Ack::is_windows ) {
        return File::Next::reslash( $filename );
    }
    else {
        # XXX Is this the best method? It always hits the FS.
        if ( my ( $dev, $inode ) = (stat($filename))[0, 1] ) {
            return join(':', $dev, $inode);
        }
        else {
            # XXX This could be better.
            return $filename;
        }
    }
}

# Returns a regex object based on a string and command-line options.
# Dies when the regex $str is undefined (i.e. not given on command line).

sub build_regex {
    my $str = shift;
    my $opt = shift;

    defined $str or App::Ack::die( 'No regular expression found.' );

    if ( !$opt->{Q} ) {
        # Compile the regex to see if it dies or throws warnings.
        local $SIG{__WARN__} = sub { die @_ };  # Anything that warns becomes a die.
        my $scratch_regex = eval { qr/$str/ };
        if ( not $scratch_regex ) {
            my $err = $@;
            chomp $err;

            if ( $err =~ m{^(.+?); marked by <-- HERE in m/(.+?) <-- HERE} ) {
                my ($why, $where) = ($1,$2);
                my $pointy = ' ' x (6+length($where)) . '^---HERE';
                App::Ack::die( "Invalid regex '$str'\nRegex: $str\n$pointy $why" );
            }
            else {
                App::Ack::die( "Invalid regex '$str'\n$err" );
            }
        }
    }

    # Check for lowercaseness before we do any modifications.
    my $regex_is_lc = App::Ack::is_lowercase( $str );

    $str = quotemeta( $str ) if $opt->{Q};

    my $scan_str = $str;

    # Whole words only.
    if ( $opt->{w} ) {
        my $ok = 1;

        if ( $str =~ /^\\[wd]/ ) {
            # Explicit \w is good.
        }
        else {
            # Can start with \w, (, [ or dot.
            if ( $str !~ /^[\w\(\[\.]/ ) {
                $ok = 0;
            }
        }

        # Can end with \w, }, ), ], +, *, or dot.
        if ( $str !~ /[\w\}\)\]\+\*\?\.]$/ ) {
            $ok = 0;
        }
        # ... unless it's escaped.
        elsif ( $str =~ /\\[\}\)\]\+\*\?\.]$/ ) {
            $ok = 0;
        }

        if ( !$ok ) {
            App::Ack::die( '-w will not do the right thing if your regex does not begin and end with a word character.' );
        }

        if ( $str =~ /^\w+$/ ) {
            # No need for fancy regex if it's a simple word.
            $str = sprintf( '\b(?:%s)\b', $str );
        }
        else {
            $str = sprintf( '(?:^|\b|\s)\K(?:%s)(?=\s|\b|$)', $str );
        }
    }

    if ( $opt->{i} || ($opt->{S} && $regex_is_lc) ) {
        $_ = "(?i)$_" for ( $str, $scan_str );
    }

    my $scan_regex = undef;
    my $regex = eval { qr/$str/ };
    if ( $regex ) {
        if ( $scan_str !~ /\$/ ) {
            # No line_scan is possible if there's a $ in the regex.
            $scan_regex = eval { qr/$scan_str/m };
        }
    }
    else {
        my $err = $@;
        chomp $err;
        App::Ack::die( "Invalid regex '$str':\n  $err" );
    }

    return ($regex, $scan_regex);
}

my $match_colno;

{

# Number of context lines
my $n_before_ctx_lines;
my $n_after_ctx_lines;

# Array to keep track of lines that might be required for a "before" context
my @before_context_buf;
# Position to insert next line in @before_context_buf
my $before_context_pos;

# Number of "after" context lines still pending
my $after_context_pending;

# Number of latest line that got printed
my $printed_lineno;

my $is_first_match;
state $has_printed_from_any_file = 0;


sub file_loop_normal {
    my $files = shift;

    $n_before_ctx_lines = $opt_output ? 0 : ($opt_B || 0);
    $n_after_ctx_lines  = $opt_output ? 0 : ($opt_A || 0);

    @before_context_buf = (undef) x $n_before_ctx_lines;
    $before_context_pos = 0;

    $is_tracking_context = $n_before_ctx_lines || $n_after_ctx_lines;

    $is_first_match = 1;

    my $nmatches = 0;
    while ( defined( my $file = $files->next ) ) {
        if ($is_tracking_context) {
            $printed_lineno = 0;
            $after_context_pending = 0;
            if ( $opt_heading ) {
                $is_first_match = 1;
            }
        }
        my $needs_line_scan = 1;
        if ( !$opt_passthru && !$opt_v ) {
            $stats{prescans}++;
            if ( $file->may_be_present( $scan_re ) ) {
                $file->reset();
            }
            else {
                $needs_line_scan = 0;
            }
        }
        if ( $needs_line_scan ) {
            $stats{linescans}++;
            $nmatches += print_matches_in_file( $file );
        }
        last if $opt_1 && $nmatches;
    }

    return $nmatches;
}


sub print_matches_in_file {
    my $file = shift;

    my $max_count = $opt_m || -1;   # Go negative for no limit so it can never reduce to 0.
    my $nmatches  = 0;
    my $filename  = $file->name;

    my $has_printed_from_this_file = 0;

    my $fh = $file->open;
    if ( !$fh ) {
        if ( $App::Ack::report_bad_filenames ) {
            App::Ack::warn( "$filename: $!" );
        }
        return 0;
    }

    my $display_filename = $filename;
    if ( $opt_show_filename && $opt_heading && $opt_color ) {
        $display_filename = Term::ANSIColor::colored($display_filename, $ENV{ACK_COLOR_FILENAME});
    }

    # Check for context before the main loop, so we don't pay for it if we don't need it.
    if ( $is_tracking_context ) {
        local $_ = undef;

        $after_context_pending = 0;

        my $in_range = range_setup();

        while ( <$fh> ) {
            chomp;
            $match_colno = undef;

            $in_range = 1 if ( $using_ranges && !$in_range && $opt_range_start && /$opt_range_start/o );

            my $does_match;
            if ( $in_range ) {
                if ( $opt_v ) {
                    $does_match = !/$search_re/o;
                }
                else {
                    if ( $does_match = /$search_re/o ) {
                        # @- = @LAST_MATCH_START
                        # @+ = @LAST_MATCH_END
                        $match_colno = $-[0] + 1;
                    }
                }
            }

            if ( $does_match && $max_count ) {
                if ( !$has_printed_from_this_file ) {
                    $stats{filematches}++;
                    if ( $opt_break && $has_printed_from_any_file ) {
                        App::Ack::print_blank_line();
                    }
                    if ( $opt_show_filename && $opt_heading ) {
                        App::Ack::say( $display_filename );
                    }
                }
                print_line_with_context( $filename, $_, $. );
                $has_printed_from_this_file = 1;
                $stats{linematches}++;
                $nmatches++;
                $max_count--;
            }
            else {
                if ( $after_context_pending ) {
                    # Disable $opt_column since there are no matches in the context lines.
                    local $opt_column = 0;
                    print_line_with_options( $filename, $_, $., '-' );
                    --$after_context_pending;
                }
                elsif ( $n_before_ctx_lines ) {
                    # Save line for "before" context.
                    $before_context_buf[$before_context_pos] = $_;
                    $before_context_pos = ($before_context_pos+1) % $n_before_ctx_lines;
                }
            }

            $in_range = 0 if ( $using_ranges && $in_range && $opt_range_end && /$opt_range_end/o );

            last if ($max_count == 0) && ($after_context_pending == 0);
        }
    }
    elsif ( $opt_passthru ) {
        local $_ = undef;

        my $in_range = range_setup();

        while ( <$fh> ) {
            chomp;

            $in_range = 1 if ( $using_ranges && !$in_range && $opt_range_start && /$opt_range_start/o );

            $match_colno = undef;
            if ( $in_range && ($opt_v xor /$search_re/o) ) {
                if ( !$opt_v ) {
                    $match_colno = $-[0] + 1;
                }
                if ( !$has_printed_from_this_file ) {
                    if ( $opt_break && $has_printed_from_any_file ) {
                        App::Ack::print_blank_line();
                    }
                    if ( $opt_show_filename && $opt_heading ) {
                        App::Ack::say( $display_filename );
                    }
                }
                print_line_with_options( $filename, $_, $., ':' );
                $has_printed_from_this_file = 1;
                $nmatches++;
                $max_count--;
            }
            else {
                if ( $opt_break && !$has_printed_from_this_file && $has_printed_from_any_file ) {
                    App::Ack::print_blank_line();
                }
                print_line_with_options( $filename, $_, $., '-', 1 );
                $has_printed_from_this_file = 1;
            }

            $in_range = 0 if ( $using_ranges && $in_range && $opt_range_end && /$opt_range_end/o );

            last if $max_count == 0;
        }
    }
    elsif ( $opt_v ) {
        local $_ = undef;

        $match_colno = undef;
        my $in_range = range_setup();

        while ( <$fh> ) {
            chomp;

            $in_range = 1 if ( $using_ranges && !$in_range && $opt_range_start && /$opt_range_start/o );

            if ( $in_range ) {
                if ( !/$search_re/o ) {
                    if ( !$has_printed_from_this_file ) {
                        if ( $opt_break && $has_printed_from_any_file ) {
                            App::Ack::print_blank_line();
                        }
                        if ( $opt_show_filename && $opt_heading ) {
                            App::Ack::say( $display_filename );
                        }
                    }
                    print_line_with_context( $filename, $_, $. );
                    $has_printed_from_this_file = 1;
                    $nmatches++;
                    $max_count--;
                }
            }

            $in_range = 0 if ( $using_ranges && $in_range && $opt_range_end && /$opt_range_end/o );

            last if $max_count == 0;
        }
    }
    else {  # Normal search: No context, no -v, no --passthru
        local $_ = undef;

        my $last_match_lineno;
        my $in_range = range_setup();

        while ( <$fh> ) {
            chomp;

            $in_range = 1 if ( $using_ranges && !$in_range && $opt_range_start && /$opt_range_start/o );

            if ( $in_range ) {
                $match_colno = undef;
                if ( /$search_re/o ) {
                    $match_colno = $-[0] + 1;
                    if ( !$has_printed_from_this_file ) {
                        $stats{filematches}++;
                        if ( $opt_break && $has_printed_from_any_file ) {
                            App::Ack::print_blank_line();
                        }
                        if ( $opt_show_filename && $opt_heading ) {
                            App::Ack::say( $display_filename );
                        }
                    }
                    if ( $opt_p ) {
                        if ( $last_match_lineno ) {
                            if ( $. > $last_match_lineno + $opt_p ) {
                                App::Ack::print_blank_line();
                            }
                        }
                        elsif ( !$opt_break && $has_printed_from_any_file ) {
                            App::Ack::print_blank_line();
                        }
                    }
                    s/[\r\n]+$//;
                    print_line_with_options( $filename, $_, $., ':' );
                    $has_printed_from_this_file = 1;
                    $nmatches++;
                    $stats{linematches}++;
                    $max_count--;
                    $last_match_lineno = $.;
                }
            }

            $in_range = 0 if ( $using_ranges && $in_range && $opt_range_end && /$opt_range_end/o );

            last if $max_count == 0;
        }
    }

    return $nmatches;
}


sub print_line_with_options {
    my ( $filename, $line, $lineno, $separator, $skip_coloring ) = @_;

    $has_printed_from_any_file = 1;
    $printed_lineno = $lineno;

    my @line_parts;

    if ( $opt_show_filename && defined($filename) ) {
        my $colno;
        $colno = get_match_colno() if $opt_column;
        if ( $opt_color ) {
            $filename = Term::ANSIColor::colored( $filename, $ENV{ACK_COLOR_FILENAME} );
            $lineno   = Term::ANSIColor::colored( $lineno,   $ENV{ACK_COLOR_LINENO} );
            $colno    = Term::ANSIColor::colored( $colno,    $ENV{ACK_COLOR_COLNO} ) if $opt_column;
        }
        if ( $opt_heading ) {
            push @line_parts, $lineno;
        }
        else {
            push @line_parts, $filename, $lineno;
        }
        push @line_parts, $colno if $opt_column;
    }

    if ( $opt_output ) {
        while ( $line =~ /$search_re/og ) {
            my $output = $opt_output;
            if ( @special_vars_used_by_opt_output ) {
                no strict;

                # Stash copies of the special variables because we can't rely
                # on them not changing in the process of doing the s///.

                my %keep = map { ($_ => ${$_} // '') } @special_vars_used_by_opt_output;
                $keep{_} = $line if exists $keep{_}; # Manually set it because $_ gets reset in a map.
                $keep{f} = $filename if exists $keep{f};
                my $special_vars_used_by_opt_output = join( '', @special_vars_used_by_opt_output );
                $output =~ s/\$([$special_vars_used_by_opt_output])/$keep{$1}/ego;
            }
            App::Ack::say( join( $separator, @line_parts, $output ) );
        }
    }
    else {
        my $underline = '';

        # We have to do underlining before any highlighting because highlighting modifies string length.
        if ( $opt_underline && !$skip_coloring ) {
            while ( $line =~ /$search_re/og ) {
                my $match_start = $-[0] // next;
                my $match_end = $+[0];
                my $match_length = $match_end - $match_start;
                last if $match_length <= 0;

                my $spaces_needed = $match_start - length $underline;

                $underline .= (' ' x $spaces_needed);
                $underline .= ('^' x $match_length);
            }
        }
        if ( $opt_color && !$skip_coloring ) {
            my $highlighted = 0; # If highlighted, need to escape afterwards.

            while ( $line =~ /$search_re/og ) {
                my $match_start = $-[0] // next;
                my $match_end = $+[0];
                my $match_length = $match_end - $match_start;
                last if $match_length <= 0;

                my $substring    = substr( $line, $match_start, $match_length );
                my $substitution = Term::ANSIColor::colored( $substring, $ENV{ACK_COLOR_MATCH} );

                # Fourth argument replaces the string specified by the first three.
                substr( $line, $match_start, $match_length, $substitution );

                # Move the offset of where /g left off forward the number of spaces of highlighting.
                pos($line) = $match_end + (length( $substitution ) - length( $substring ));
                $highlighted = 1;
            }
            # Reset formatting and delete everything to the end of the line.
            $line .= "\e[0m\e[K" if $highlighted;
        }

        push @line_parts, $line;
        App::Ack::say( join( $separator, @line_parts ) );

        # Print the underline, if appropriate.
        if ( $underline ne '' ) {
            # Figure out how many spaces are used per line for the ANSI coloring.
            state $chars_used_by_coloring;
            if ( !defined($chars_used_by_coloring) ) {
                $chars_used_by_coloring = 0;
                if ( $opt_color ) {
                    my $len_fn = sub { length( Term::ANSIColor::colored( 'x', $ENV{$_[0]} ) ) - 1 };
                    $chars_used_by_coloring += $len_fn->('ACK_COLOR_FILENAME') unless $opt_heading;
                    $chars_used_by_coloring += $len_fn->('ACK_COLOR_LINENO');
                    $chars_used_by_coloring += $len_fn->('ACK_COLOR_COLNO') if $opt_column;
                }
            }

            pop @line_parts; # Leave only the stuff on the left.
            if ( @line_parts ) {
                my $stuff_on_the_left = join( $separator, @line_parts );
                my $spaces_needed = length($stuff_on_the_left) - $chars_used_by_coloring + 1;

                App::Ack::print( ' ' x $spaces_needed );
            }
            App::Ack::say( $underline );
        }
    }

    return;
}

sub print_line_with_context {
    my ( $filename, $matching_line, $lineno ) = @_;

    $matching_line =~ s/[\r\n]+$//;

    # Check if we need to print context lines first.
    if ( $opt_A || $opt_B ) {
        my $before_unprinted = $lineno - $printed_lineno - 1;
        if ( !$is_first_match && ( !$printed_lineno || $before_unprinted > $n_before_ctx_lines ) ) {
            App::Ack::say( '--' );
        }

        # We want at most $n_before_ctx_lines of context.
        if ( $before_unprinted > $n_before_ctx_lines ) {
            $before_unprinted = $n_before_ctx_lines;
        }

        while ( $before_unprinted > 0 ) {
            my $line = $before_context_buf[($before_context_pos - $before_unprinted + $n_before_ctx_lines) % $n_before_ctx_lines];

            chomp $line;

            # Disable $opt->{column} since there are no matches in the context lines.
            local $opt_column = 0;

            print_line_with_options( $filename, $line, $lineno-$before_unprinted, '-' );
            $before_unprinted--;
        }
    }

    print_line_with_options( $filename, $matching_line, $lineno, ':' );

    # We want to get the next $n_after_ctx_lines printed.
    $after_context_pending = $n_after_ctx_lines;

    $is_first_match = 0;

    return;
}

}

sub get_match_colno {
    return $match_colno;
}

sub count_matches_in_file {
    my $file = shift;
    my $bail = shift;   # True if we're just checking for existence.

    my $nmatches = 0;
    my $do_scan = 1;

    if ( !$file->open() ) {
        $do_scan = 0;
        if ( $App::Ack::report_bad_filenames ) {
            App::Ack::warn( $file->name . ": $!" );
        }
    }
    else {
        if ( !$opt_v ) {
            if ( !$file->may_be_present( $scan_re ) ) {
                $do_scan = 0;
            }
        }
    }

    if ( $do_scan ) {
        $file->reset();

        my $in_range = range_setup();

        my $fh = $file->{fh};
        if ( $using_ranges ) {
            while ( <$fh> ) {
                chomp;
                $in_range = 1 if ( !$in_range && $opt_range_start && /$opt_range_start/o );
                if ( $in_range ) {
                    if ( /$search_re/o xor $opt_v ) {
                        ++$nmatches;
                        last if $bail;
                    }
                }
                $in_range = 0 if ( $in_range && $opt_range_end && /$opt_range_end/o );
            }
        }
        else {
            while ( <$fh> ) {
                chomp;
                if ( /$search_re/o xor $opt_v ) {
                    ++$nmatches;
                    last if $bail;
                }
            }
        }
    }
    $file->close;

    return $nmatches;
}


sub range_setup {
    return !$using_ranges || (!$opt_range_start && $opt_range_end);
}


=pod

=encoding UTF-8

=head1 NAME

ack - grep-like text finder

=head1 SYNOPSIS

    ack [options] PATTERN [FILE...]
    ack -f [options] [DIRECTORY...]

=head1 DESCRIPTION

ack is designed as an alternative to F<grep> for programmers.

ack searches the named input FILEs or DIRECTORYs for lines containing a
match to the given PATTERN.  By default, ack prints the matching lines.
If no FILE or DIRECTORY is given, the current directory will be searched.

PATTERN is a Perl regular expression.  Perl regular expressions
are commonly found in other programming languages, but for the particulars
of their behavior, please consult
L<perlreref|https://perldoc.perl.org/perlreref.html>.  If you don't know
how to use regular expression but are interested in learning, you may
consult L<perlretut|https://perldoc.perl.org/perlretut.html>.  If you do not
need or want ack to use regular expressions, please see the
C<-Q>/C<--literal> option.

Ack can also list files that would be searched, without actually
searching them, to let you take advantage of ack's file-type filtering
capabilities.

=head1 FILE SELECTION

If files are not specified for searching, either on the command
line or piped in with the C<-x> option, I<ack> delves into
subdirectories selecting files for searching.

I<ack> is intelligent about the files it searches.  It knows about
certain file types, based on both the extension on the file and,
in some cases, the contents of the file.  These selections can be
made with the B<--type> option.

With no file selection, I<ack> searches through regular files that
are not explicitly excluded by B<--ignore-dir> and B<--ignore-file>
options, either present in F<ackrc> files or on the command line.

The default options for I<ack> ignore certain files and directories.  These
include:

=over 4

=item * Backup files: Files matching F<#*#> or ending with F<~>.

=item * Coredumps: Files matching F<core.\d+>

=item * Version control directories like F<.svn> and F<.git>.

=back

Run I<ack> with the C<--dump> option to see what settings are set.

However, I<ack> always searches the files given on the command line,
no matter what type.  If you tell I<ack> to search in a coredump,
it will search in a coredump.

=head1 DIRECTORY SELECTION

I<ack> descends through the directory tree of the starting directories
specified.  If no directories are specified, the current working directory is
used.  However, it will ignore the shadow directories used by
many version control systems, and the build directories used by the
Perl MakeMaker system.  You may add or remove a directory from this
list with the B<--[no]ignore-dir> option. The option may be repeated
to add/remove multiple directories from the ignore list.

For a complete list of directories that do not get searched, run
C<ack --dump>.

=head1 MATCHING IN A RANGE OF LINES

The C<--range-start> and C<--range-end> options let you specify ranges of
lines to search within each file.

Say you had the following file, called F<testfile>:

    # This function calls print on "foo".
    sub foo {
        print 'foo';
    }
    my $print = 1;
    sub bar {
        print 'bar';
    }
    my $task = 'print';

Calling C<ack print> will give us five matches:

    $ ack print testfile
    # This function calls print on "foo".
        print 'foo';
    my $print = 1;
        print 'bar';
    my $task = 'print';

What if we only want to search for C<print> within the subroutines?  We can
specify ranges of lines that we want ack to search.  The range starts with
any line that matches the pattern C<^sub \w+>, and stops with any line that
matches C<^}>.

    $ ack --range-start='^sub \w+' --range-end='^}' print testfile
        print 'foo';
        print 'bar';

Note that ack searched two ranges of lines.  The listing below shows which
lines were in a range and which were out of the range.

    Out # This function calls print on "foo".
    In  sub foo {
    In      print 'foo';
    In  }
    Out my $print = 1;
    In  sub bar {
    In      print 'bar';
    In  }
    Out my $task = 'print';

You don't have to specify both C<--range-start> and C<--range-end>.  IF
C<--range-start> is omitted, then the range runs from the first line in the
file unitl the first line that matches C<--range-end>.  Similarly, if
C<--range-end> is omitted, the range runs from the first line matching
C<--range-start> to the end of the file.

For example, if you wanted to search all HTML files up until the first
instance of the C<< <body> >>, you could do

    ack foo --range-end='<body>'

Or to search after Perl's `__DATA__` or `__END__` markers, you would do

    ack pattern --range-end='^__(END|DATA)__'

It's possible for a range to start and stop on the same line.  For example

    --range-start='<title>' --range-end='</title>'

would match this line as both the start and end of the range, making a
one-line range.

    <title>Page title</title>

Note that the patterns in C<--range-start> and C<--range-end> are not
affected by options like C<-i>, C<-w> and C<-Q> that modify the behavior of
the main pattern being matched.

Again, ranges only affect where matches are looked for.  Everything else in
ack works the same way.  Using C<-c> option with a range will give a count
of all the matches that appear within those ranges.  The C<-l> shows those
files that have a match within a range, and the C<-L> option shows files
that do not have a match within a range.

The C<-v> option for negating a match works inside the range, too.
To see lines that don't match "google" within the "<head>" section of
your HTML files, you could do:

    ack google -v --html --range-start='<head' --range-end='</head>'

Specifying a range to search does not affect how matches are displayed.
The context for a match will still be the same, and

Using the context options work the same way, and will show context
lines for matches even if the context lines fall outside the range.
Similarly, C<--passthru> will show all lines in the file, but only show
matches for lines within the range.

=head1 OPTIONS

=over 4

=item B<--ackrc>

Specifies an ackrc file to load after all others; see L</"ACKRC LOCATION SEMANTICS">.

=item B<-A I<NUM>>, B<--after-context=I<NUM>>

Print I<NUM> lines of trailing context after matching lines.

=item B<-B I<NUM>>, B<--before-context=I<NUM>>

Print I<NUM> lines of leading context before matching lines.

=item B<--[no]break>

Print a break between results from different files. On by default
when used interactively.

=item B<-C [I<NUM>]>, B<--context[=I<NUM>]>

Print I<NUM> lines (default 2) of context around matching lines.
You can specify zero lines of context to override another context
specified in an ackrc.

=item B<-c>, B<--count>

Suppress normal output; instead print a count of matching lines for
each input file.  If B<-l> is in effect, it will only show the
number of lines for each file that has lines matching.  Without
B<-l>, some line counts may be zeroes.

If combined with B<-h> (B<--no-filename>) ack outputs only one total
count.

=item B<--[no]color>, B<--[no]colour>

B<--color> highlights the matching text.  B<--nocolor> suppresses
the color.  This is on by default unless the output is redirected.

On Windows, this option is off by default unless the
L<Win32::Console::ANSI> module is installed or the C<ACK_PAGER_COLOR>
environment variable is used.

=item B<--color-filename=I<color>>

Sets the color to be used for filenames.

=item B<--color-match=I<color>>

Sets the color to be used for matches.

=item B<--color-colno=I<color>>

Sets the color to be used for column numbers.

=item B<--color-lineno=I<color>>

Sets the color to be used for line numbers.

=item B<--[no]column>

Show the column number of the first match.  This is helpful for
editors that can place your cursor at a given position.

=item B<--create-ackrc>

Dumps the default ack options to standard output.  This is useful for
when you want to customize the defaults.

=item B<--dump>

Writes the list of options loaded and where they came from to standard
output.  Handy for debugging.

=item B<--[no]env>

B<--noenv> disables all environment processing. No F<.ackrc> is
read and all environment variables are ignored. By default, F<ack>
considers F<.ackrc> and settings in the environment.

=item B<--flush>

B<--flush> flushes output immediately.  This is off by default
unless ack is running interactively (when output goes to a pipe or
file).

=item B<-f>

Only print the files that would be searched, without actually doing
any searching.  PATTERN must not be specified, or it will be taken
as a path to search.

=item B<--files-from=I<FILE>>

The list of files to be searched is specified in I<FILE>.  The list of
files are separated by newlines.  If I<FILE> is C<->, the list is loaded
from standard input.

Note that the list of files is B<not> filtered in any way.  If you
add C<--type=html> in addition to C<--files-from>, the C<--type> will
be ignored.


=item B<--[no]filter>

Forces ack to act as if it were receiving input via a pipe.

=item B<--[no]follow>

Follow or don't follow symlinks, other than whatever starting files
or directories were specified on the command line.

This is off by default.

=item B<-g I<PATTERN>>

Print searchable files where the relative path + filename matches
I<PATTERN>.

Note that

    ack -g foo

is exactly the same as

    ack -f | ack foo

This means that just as ack will not search, for example, F<.jpg>
files, C<-g> will not list F<.jpg> files either.  ack is not intended
to be a general-purpose file finder.

Note also that if you have C<-i> in your .ackrc that the filenames
to be matched will be case-insensitive as well.

This option can be combined with B<--color> to make it easier to
spot the match.

=item B<--[no]group>

B<--group> groups matches by file name.  This is the default
when used interactively.

B<--nogroup> prints one result per line, like grep.  This is the
default when output is redirected.

=item B<-H>, B<--with-filename>

Print the filename for each match. This is the default unless searching
a single explicitly specified file.

=item B<-h>, B<--no-filename>

Suppress the prefixing of filenames on output when multiple files are
searched.

=item B<--[no]heading>

Print a filename heading above each file's results.  This is the default
when used interactively.

=item B<--help>

Print a short help statement.

=item B<--help-types>

Print all known types.

=item B<--help-colors>

Print a chart of various color combinations.

=item B<--help-rgb-colors>

Like B<--help-colors> but with more precise RGB colors.

=item B<-i>, B<--ignore-case>

Ignore case distinctions in PATTERN.  Overrides B<--smart-case> and B<-I>.

=item B<-I>, B<--no-ignore-case>

Turns on case distinctions in PATTERN.  Overrides B<--smart-case> and B<-i>.

=item B<--ignore-ack-defaults>

Tells ack to completely ignore the default definitions provided with ack.
This is useful in combination with B<--create-ackrc> if you I<really> want
to customize ack.

=item B<--[no]ignore-dir=I<DIRNAME>>, B<--[no]ignore-directory=I<DIRNAME>>

Ignore directory (as CVS, .svn, etc are ignored). May be used
multiple times to ignore multiple directories. For example, mason
users may wish to include B<--ignore-dir=data>. The B<--noignore-dir>
option allows users to search directories which would normally be
ignored (perhaps to research the contents of F<.svn/props> directories).

The I<DIRNAME> must always be a simple directory name. Nested
directories like F<foo/bar> are NOT supported. You would need to
specify B<--ignore-dir=foo> and then no files from any foo directory
are taken into account by ack unless given explicitly on the command
line.

=item B<--ignore-file=I<FILTER:ARGS>>

Ignore files matching I<FILTER:ARGS>.  The filters are specified
identically to file type filters as seen in L</"Defining your own types">.

=item B<-k>, B<--known-types>

Limit selected files to those with types that ack knows about.

=item B<-l>, B<--files-with-matches>

Only print the filenames of matching files, instead of the matching text.

=item B<-L>, B<--files-without-matches>

Only print the filenames of files that do I<NOT> match.

=item B<--match I<PATTERN>>

Specify the I<PATTERN> explicitly. This is helpful if you don't want to put the
regex as your first argument, e.g. when executing multiple searches over the
same set of files.

    # search for foo and bar in given files
    ack file1 t/file* --match foo
    ack file1 t/file* --match bar

=item B<-m=I<NUM>>, B<--max-count=I<NUM>>

Print only I<NUM> matches out of each file.  If you want to stop ack
after printing the first match of any kind, use the B<-1> options.

=item B<--man>

Print this manual page.

=item B<-n>, B<--no-recurse>

No descending into subdirectories.

=item B<-o>

Show only the part of each line matching PATTERN (turns off text
highlighting).  This is exactly the same as C<--output=$&>.

=item B<--output=I<expr>>

Output the evaluation of I<expr> for each line (turns off text
highlighting). If PATTERN matches more than once then a line is
output for each non-overlapping match.

I<expr> may contain the strings "\n", "\r" and "\t", which will be
expanded to their corresponding characters line feed, carriage return
and tab, respectively.

I<expr> may also contain the following Perl special variables:

=over 4

=item C<$1> through C<$9>

The subpattern from the corresponding set of capturing parentheses.
If your pattern is C<(.+) and (.+)>, and the string is "this and
that', then C<$1> is "this" and C<$2> is "that".

=item C<$_>

The contents of the line in the file.

=item C<$.>

The number of the line in the file.

=item C<$&>, C<$`> and C<$'>

C<$&> is the the string matched by the pattern, C<$`> is what
precedes the match, and C<$'> is what follows it.  If the pattern
is C<gra(ph|nd)> and the string is "lexicographic", then C<$&> is
"graph", C<$`> is "lexico" and C<$'> is "ic".

Use of these variables in your output will slow down the pattern
matching.

=item C<$+>

The match made by the last parentheses that matched in the pattern.
For example, if your pattern is C<Version: (.+)|Revision: (.+)>,
then C<$+> will contain whichever set of parentheses matched.

=item C<$f>

C<$f> is available, in C<--output> only, to insert the filename.
This is a stand-in for the discovered C<$filename> usage in old C<< ack2 --output >>,
which is disallowed with C<ack3> improved security.

The intended usage is to provide the grep or compile-error syntax needed for editor/IDE go-to-line integration,
e.g. C<--output=$f:$.:$_> or C<--output=$f\t$.\t$&>

=back

=item B<--pager=I<program>>, B<--nopager>

B<--pager> directs ack's output through I<program>.  This can also be specified
via the C<ACK_PAGER> and C<ACK_PAGER_COLOR> environment variables.

Using --pager does not suppress grouping and coloring like piping
output on the command-line does.

B<--nopager> cancels any setting in F<~/.ackrc>, C<ACK_PAGER> or C<ACK_PAGER_COLOR>.
No output will be sent through a pager.

=item B<--passthru>

Prints all lines, whether or not they match the expression.  Highlighting
will still work, though, so it can be used to highlight matches while
still seeing the entire file, as in:

    # Watch a log file, and highlight a certain IP address.
    $ tail -f ~/access.log | ack --passthru 123.45.67.89

=item B<--print0>

Only works in conjunction with B<-f>, B<-g>, B<-l> or B<-c>, options
that only list filenames.  The filenames are output separated with a
null byte instead of the usual newline. This is helpful when dealing
with filenames that contain whitespace, e.g.

    # Remove all files of type HTML.
    ack -f --html --print0 | xargs -0 rm -f

=item B<-p[N]>, B<--proximate[=N]>

Groups together match lines that are within N lines of each other.
This is useful for visually picking out matches that appear close
to other matches.

For example, if you got these results without the C<--proximate> option,

    15: First match
    18: Second match
    19: Third match
    37: Fourth match

they would look like this with C<--proximate=1>

    15: First match

    18: Second match
    19: Third match

    37: Fourth match

and this with C<--proximate=3>.

    15: First match
    18: Second match
    19: Third match

    37: Fourth match

If N is omitted, N is set to 1.

=item B<-P>

Negates the effect of the B<--proximate> option.  Shortcut for B<--proximate=0>.

=item B<-Q>, B<--literal>

Quote all metacharacters in PATTERN, it is treated as a literal.

=item B<-r>, B<-R>, B<--recurse>

Recurse into sub-directories. This is the default and just here for
compatibility with grep. You can also use it for turning B<--no-recurse> off.

=item B<--range-start=PATTERN>, B<--range-end=PATTERN>

Specifies patterns that mark the start and end of a range.  See
L<MATCHING IN A RANGE OF LINES> for details.

=item B<-s>

Suppress error messages about nonexistent or unreadable files.  This is taken
from fgrep.

=item B<-S>, B<--[no]smart-case>, B<--no-smart-case>

Ignore case in the search strings if PATTERN contains no uppercase
characters. This is similar to C<smartcase> in the vim text editor.
The options overrides B<-i> and B<-I>.

B<-S> is a synonym for B<--smart-case>.

B<-i> always overrides this option.

=item B<--sort-files>

Sorts the found files lexicographically.  Use this if you want your file
listings to be deterministic between runs of I<ack>.

=item B<--show-types>

Outputs the filetypes that ack associates with each file.

Works with B<-f> and B<-g> options.

=item B<-t TYPE>, B<--type=TYPE>, B<--TYPE>

Specify the types of files to include in the search.
TYPE is a filetype, like I<perl> or I<xml>.  B<--type=perl> can
also be specified as B<--perl>, although this is deprecated.

Type inclusions can be repeated and are ORed together.

See I<ack --help-types> for a list of valid types.

=item B<-T TYPE>, B<--type=noTYPE>, B<--noTYPE>

Specifies the type of files to exclude from the search.  B<--type=noperl>
can be done as B<--noperl>, although this is deprecated.

If a file is of both type "foo" and "bar", specifying both B<--type=foo>
and B<--type=nobar> will exclude the file, because an exclusion takes
precedence over an inclusion.

=item B<--type-add I<TYPE>:I<FILTER>:I<ARGS>>

Files with the given ARGS applied to the given FILTER
are recognized as being of (the existing) type TYPE.
See also L</"Defining your own types">.

=item B<--type-set I<TYPE>:I<FILTER>:I<ARGS>>

Files with the given ARGS applied to the given FILTER are recognized as
being of type TYPE. This replaces an existing definition for type TYPE.  See
also L</"Defining your own types">.

=item B<--type-del I<TYPE>>

The filters associated with TYPE are removed from Ack, and are no longer considered
for searches.

=item B<--[no]underline>

Turns on underlining of matches, where "underlining" is printing a line of
carets under the match.

    $ ack -u foo
    peanuts.txt
    17: Come kick the football you fool
                      ^^^          ^^^
    623: Price per square foot
                          ^^^

This is useful if you're dumping the results of an ack run into a text
file or printer that doesn't support ANSI color codes.

The setting of underline does not affect highlighting of matches.

=item B<-v>, B<--invert-match>

Invert match: select non-matching lines.

=item B<--version>

Display version and copyright information.

=item B<-w>, B<--word-regexp>

Force PATTERN to match only whole words.

=item B<-x>

An abbreviation for B<--files-from=->. The list of files to search are read
from standard input, with one line per file.

Note that the list of files is B<not> filtered in any way.  If you add
C<--type=html> in addition to C<-x>, the C<--type> will be ignored.

=item B<-1>

Stops after reporting first match of any kind.  This is different
from B<--max-count=1> or B<-m1>, where only one match per file is
shown.  Also, B<-1> works with B<-f> and B<-g>, where B<-m> does
not.

=item B<--thpppt>

Display the all-important Bill The Cat logo.  Note that the exact
spelling of B<--thpppppt> is not important.  It's checked against
a regular expression.

=item B<--bar>

Check with the admiral for traps.

=item B<--cathy>

Chocolate, Chocolate, Chocolate!

=back

=head1 THE .ackrc FILE

The F<.ackrc> file contains command-line options that are prepended
to the command line before processing.  Multiple options may live
on multiple lines.  Lines beginning with a # are ignored.  A F<.ackrc>
might look like this:

    # Always sort the files
    --sort-files

    # Always color, even if piping to another program
    --color

    # Use "less -r" as my pager
    --pager=less -r

Note that arguments with spaces in them do not need to be quoted,
as they are not interpreted by the shell. Basically, each I<line>
in the F<.ackrc> file is interpreted as one element of C<@ARGV>.

F<ack> looks in several locations for F<.ackrc> files; the searching
process is detailed in L</"ACKRC LOCATION SEMANTICS">.  These
files are not considered if B<--noenv> is specified on the command line.

=head1 Defining your own types

ack allows you to define your own types in addition to the predefined
types. This is done with command line options that are best put into
an F<.ackrc> file - then you do not have to define your types over and
over again. In the following examples the options will always be shown
on one command line so that they can be easily copy & pasted.

File types can be specified both with the the I<--type=xxx> option,
or the file type as an option itself.  For example, if you create
a filetype of "cobol", you can specify I<--type=cobol> or simply
I<--cobol>.  File types must be at least two characters long.  This
is why the C language is I<--cc> and the R language is I<--rr>.

I<ack --perl foo> searches for foo in all perl files. I<ack --help-types>
tells you, that perl files are files ending
in .pl, .pm, .pod or .t. So what if you would like to include .xs
files as well when searching for --perl files? I<ack --type-add perl:ext:xs --perl foo>
does this for you. B<--type-add> appends
additional extensions to an existing type.

If you want to define a new type, or completely redefine an existing
type, then use B<--type-set>. I<ack --type-set eiffel:ext:e,eiffel> defines
the type I<eiffel> to include files with
the extensions .e or .eiffel. So to search for all eiffel files
containing the word Bertrand use I<ack --type-set eiffel:ext:e,eiffel --eiffel Bertrand>.
As usual, you can also write B<--type=eiffel>
instead of B<--eiffel>. Negation also works, so B<--noeiffel> excludes
all eiffel files from a search. Redefining also works: I<ack --type-set cc:ext:c,h>
and I<.xs> files no longer belong to the type I<cc>.

When defining your own types in the F<.ackrc> file you have to use
the following:

  --type-set=eiffel:ext:e,eiffel

or writing on separate lines

  --type-set
  eiffel:ext:e,eiffel

The following does B<NOT> work in the F<.ackrc> file:

  --type-set eiffel:ext:e,eiffel

In order to see all currently defined types, use I<--help-types>, e.g.
I<ack --type-set backup:ext:bak --type-add perl:ext:perl --help-types>

In addition to filtering based on extension, ack offers additional
filter types.  The generic syntax is
I<--type-set TYPE:FILTER:ARGS>; I<ARGS> depends on the value
of I<FILTER>.

=over 4

=item is:I<FILENAME>

I<is> filters match the target filename exactly.  It takes exactly one
argument, which is the name of the file to match.

Example:

    --type-set make:is:Makefile

=item ext:I<EXTENSION>[,I<EXTENSION2>[,...]]

I<ext> filters match the extension of the target file against a list
of extensions.  No leading dot is needed for the extensions.

Example:

    --type-set perl:ext:pl,pm,t

=item match:I<PATTERN>

I<match> filters match the target filename against a regular expression.
The regular expression is made case-insensitive for the search.

Example:

    --type-set make:match:/(gnu)?makefile/

=item firstlinematch:I<PATTERN>

I<firstlinematch> matches the first line of the target file against a
regular expression.  Like I<match>, the regular expression is made
case insensitive.

Example:

    --type-add perl:firstlinematch:/perl/

=back

=head1 ACK COLORS

ack allows customization of the colors it uses when presenting matches
onscreen.  It uses the colors available in Perl's L<Term::ANSIColor>
module, which provides the following listed values. Note that case does not
matter when using these values.

There are four different colors ack uses:

    Aspect      Option              Env. variable       Default
    --------    -----------------   ------------------  ---------------
    filename    --color-filename    ACK_COLOR_FILENAME  black on_yellow
    match       --color-match       ACK_COLOR_MATCH     bold green
    line no.    --color-lineno      ACK COLOR_LINENO    bold yellow
    column no.  --color-colno       ACK COLOR_COLNO     bold yellow

The column number column is only used if the column number is shown because
of the --column option.

Colors may be specified by command-line option, such as
C<ack --color-filename='red on_white'>, or by setting an environment
variable, such as C<ACK_COLOR_FILENAME='red on_white'>.  Options for colors
can be set in your ACKRC file (See "THE .ackrc FILE").

ack can understand the following colors for the foreground:

    black red green yellow blue magenta cyan white

The optional background color is specified by prepending "on_" to one of
the foreground colors:

    on_black on_red on_green on_yellow on_blue on_magenta on_cyan on_white

Each of the foreground colors can be modified with the following
attributes, which may or may not be supported by your terminal:

    bold faint italic underline blink reverse concealed

Any combinations of modifiers can be added to the foreground color. If your
terminal supports it, and you enjoy visual punishment, you can specify:

    ack --color-filename="blink italic underline bold red on_yellow"

For charts of the colors and what they look like, run C<ack --help-colors>
and C<ack --help-rgb-colors>.

If the eight standard colors, in their bold, faint and unmodified states,
aren't enough for you to choose from, you can also specify colors by their
RGB values.  They are specified as "rgbXYZ" where X, Y, and Z are values
between 0 and 5 giving the intensity of red, green and blue, respectively.
Therefore, "rgb500" is pure red, "rgb505" is purple, and so on.

Background colors can be specified with the "on_" prefix prepended on an
RGB color, so that "on_rgb505" would be a purple background.

The modifier attributes of blink, italic, underscore and so on may or may
not work on the RGB colors.

For a chart of the 216 possible RGB colors, run C<ack --help-rgb-colors>.

=head1 ENVIRONMENT VARIABLES

For commonly-used ack options, environment variables can make life
much easier.  These variables are ignored if B<--noenv> is specified
on the command line.

=over 4

=item ACKRC

Specifies the location of the user's F<.ackrc> file.  If this file doesn't
exist, F<ack> looks in the default location.

=item ACK_COLOR_COLNO

Color specification for the column number in ack's output.  By default, the
column number is not shown.  You have to enable it with the B<--column>
option.  See the section "ack Colors" above.

=item ACK_COLOR_FILENAME

Color specification for the filename in ack's output.  See the section "ack
Colors" above.

=item ACK_COLOR_LINENO

Color specification for the line number in ack's output.  See the section
"ack Colors" above.

=item ACK_COLOR_MATCH

Color specification for the matched text in ack's output.  See the section
"ack Colors" above.

=item ACK_PAGER

Specifies a pager program, such as C<more>, C<less> or C<most>, to which
ack will send its output.

Using C<ACK_PAGER> does not suppress grouping and coloring like
piping output on the command-line does, except that on Windows
ack will assume that C<ACK_PAGER> does not support color.

C<ACK_PAGER_COLOR> overrides C<ACK_PAGER> if both are specified.

=item ACK_PAGER_COLOR

Specifies a pager program that understands ANSI color sequences.
Using C<ACK_PAGER_COLOR> does not suppress grouping and coloring
like piping output on the command-line does.

If you are not on Windows, you never need to use C<ACK_PAGER_COLOR>.

=back

=head1 ACK & OTHER TOOLS

=head2 Simple vim integration

F<ack> integrates easily with the Vim text editor. Set this in your
F<.vimrc> to use F<ack> instead of F<grep>:

    set grepprg=ack\ -k

That example uses C<-k> to search through only files of the types ack
knows about, but you may use other default flags. Now you can search
with F<ack> and easily step through the results in Vim:

  :grep Dumper perllib

=head2 Editor integration

Many users have integrated ack into their preferred text editors.
For details and links, see L<https://beyondgrep.com/more-tools/>.

=head2 Shell and Return Code

For greater compatibility with I<grep>, I<ack> in normal use returns
shell return or exit code of 0 only if something is found and 1 if
no match is found.

(Shell exit code 1 is C<$?=256> in perl with C<system> or backticks.)

The I<grep> code 2 for errors is not used.

If C<-f> or C<-g> are specified, then 0 is returned if at least one
file is found.  If no files are found, then 1 is returned.

=cut

=head1 DEBUGGING ACK PROBLEMS

If ack gives you output you're not expecting, start with a few simple steps.

=head2 Try it with B<--noenv>

Your environment variables and F<.ackrc> may be doing things you're
not expecting, or forgotten you specified.  Use B<--noenv> to ignore
your environment and F<.ackrc>.

=head2 Use B<-f> to see what files have been selected for searching

Ack's B<-f> was originally added as a debugging tool.  If ack is
not finding matches you think it should find, run F<ack -f> to see
what files have been selected.  You can also add the C<--show-types>
options to show the type of each file selected.

=head2 Use B<--dump>

This lists the ackrc files that are loaded and the options loaded
from them.  You may be loading an F<.ackrc> file that you didn't know
you were loading.

=head1 ACKRC LOCATION SEMANTICS

Ack can load its configuration from many sources.  The following list
specifies the sources Ack looks for configuration files; each one
that is found is loaded in the order specified here, and
each one overrides options set in any of the sources preceding
it.  (For example, if I set --sort-files in my user ackrc, and
--nosort-files on the command line, the command line takes
precedence)

=over 4

=item *

Defaults are loaded from App::Ack::ConfigDefaults.  This can be omitted
using C<--ignore-ack-defaults>.

=item * Global ackrc

Options are then loaded from the global ackrc.  This is located at
C</etc/ackrc> on Unix-like systems.

Under Windows XP and earlier, the global ackrc is at
C<C:\Documents and Settings\All Users\Application Data\ackrc>

Under Windows Vista/7, the global ackrc is at
C<C:\ProgramData\ackrc>

The C<--noenv> option prevents all ackrc files from being loaded.

=item * User ackrc

Options are then loaded from the user's ackrc.  This is located at
C<$HOME/.ackrc> on Unix-like systems.

Under Windows XP and earlier, the user's ackrc is at
C<C:\Documents and Settings\$USER\Application Data\ackrc>.

Under Windows Vista/7, the user's ackrc is at
C<C:\Users\$USER\AppData\Roaming\ackrc>.

If you want to load a different user-level ackrc, it may be specified
with the C<$ACKRC> environment variable.

The C<--noenv> option prevents all ackrc files from being loaded.

=item * Project ackrc

Options are then loaded from the project ackrc.  The project ackrc is
the first ackrc file with the name C<.ackrc> or C<_ackrc>, first searching
in the current directory, then the parent directory, then the grandparent
directory, etc.  This can be omitted using C<--noenv>.

=item * --ackrc

The C<--ackrc> option may be included on the command line to specify an
ackrc file that can override all others.  It is consulted even if C<--noenv>
is present.

=item * Command line

Options are then loaded from the command line.

=back

=head1 BUGS & ENHANCEMENTS

ack is based at GitHub at L<https://github.com/beyondgrep/ack3>

Please report any bugs or feature requests to the issues list at
Github: L<https://github.com/beyondgrep/ack3/issues>.

Please include the operating system that you're using; the output of
the command C<ack --version>; and any customizations in your F<.ackrc>
you may have.

To suggest enhancements, please submit an issue at
L<https://github.com/beyondgrep/ack3/issues>.  Also read the
F<DEVELOPERS.md> file in the ack code repository.

Also, feel free to discuss your issues on the ack mailing
list at L<https://groups.google.com/group/ack-users>.

=head1 SUPPORT

Support for and information about F<ack> can be found at:

=over 4

=item * The ack homepage

L<https://beyondgrep.com/>

=item * Source repository

L<https://github.com/beyondgrep/ack3>

=item * The ack issues list at Github

L<https://github.com/beyondgrep/ack3/issues>

=item * The ack announcements mailing list

L<https://groups.google.com/group/ack-announcement>

=item * The ack users' mailing list

L<https://groups.google.com/group/ack-users>

=item * The ack development mailing list

L<https://groups.google.com/group/ack-users>

=back

=head1 COMMUNITY

There are ack mailing lists and a Slack channel for ack.  See
L<https://beyondgrep.com/community/> for details.

=head1 FAQ

This is the Frequently Asked Questions list for ack.

=head2 Can I stop using grep now?

Many people find I<ack> to be better than I<grep> as an everyday tool
99% of the time, but don't throw I<grep> away, because there are times
you'll still need it.  For example, you might be looking through huge
log files and not using regular expressions.  In that case, I<grep>
will probably perform better.

=head2 Why isn't ack finding a match in (some file)?

First, take a look and see if ack is even looking at the file.  ack is
intelligent in what files it will search and which ones it won't, but
sometimes that can be surprising.

Use the C<-f> switch, with no regex, to see a list of files that ack
will search for you.  If your file doesn't show up in the list of files
that C<ack -f> shows, then ack never looks in it.

=head2 Wouldn't it be great if F<ack> did search & replace?

No, ack will always be read-only.  Perl has a perfectly good way
to do search & replace in files, using the C<-i>, C<-p> and C<-n>
switches.

You can certainly use ack to select your files to update.  For
example, to change all "foo" to "bar" in all PHP files, you can do
this from the Unix shell:

    $ perl -i -p -e's/foo/bar/g' $(ack -f --php)

=head2 Can I make ack recognize F<.xyz> files?

Yes!  Please see L</"Defining your own types"> in the ack manual.

=head2 Will you make ack recognize F<.xyz> files by default?

We might, depending on how widely-used the file format is.

Submit an issue at in the GitHub issue queue at
L<https://github.com/beyondgrep/ack3/issues>.  Explain what the file format
is, where we can find out more about it, and what you have been using
in your F<.ackrc> to support it.

Please do not bother creating a pull request.  The code for filetypes
is trivial compared to the rest of the process we go through.

=head2 Why is it called ack if it's called ack-grep?

The name of the program is "ack".  Some packagers have called it
"ack-grep" when creating packages because there's already a package
out there called "ack" that has nothing to do with this ack.

I suggest you make a symlink named F<ack> that points to F<ack-grep>
because one of the crucial benefits of ack is having a name that's
so short and simple to type.

To do that, run this with F<sudo> or as root:

   ln -s /usr/bin/ack-grep /usr/bin/ack

Alternatively, you could use a shell alias:

    # bash/zsh
    alias ack=ack-grep

    # csh
    alias ack ack-grep

=head2 What does F<ack> mean?

Nothing.  I wanted a name that was easy to type and that you could
pronounce as a single syllable.

=head2 Can I do multi-line regexes?

No, ack does not support regexes that match multiple lines.  Doing
so would require reading in the entire file at a time.

If you want to see lines near your match, use the C<--A>, C<--B>
and C<--C> switches for displaying context.

=head2 Why is ack telling me I have an invalid option when searching for C<+foo>?

ack treats command line options beginning with C<+> or C<-> as options; if you
would like to search for these, you may prefix your search term with C<--> or
use the C<--match> option.  (However, don't forget that C<+> is a regular
expression metacharacter!)

=head2 Why does C<"ack '.{40000,}'"> fail?  Isn't that a valid regex?

The Perl language limits the repetition quantifier to 32K.  You
can search for C<.{32767}> but not C<.{32768}>.

=head2 Ack does "X" and shouldn't, should it?

We try to remain as close to grep's behavior as possible, so when in
doubt, see what grep does!  If there's a mismatch in functionality there,
please submit an issue to GitHub, and/or bring it up on the ack-users
mailing list.

=cut

=head1 ACKNOWLEDGEMENTS

How appropriate to have I<ack>nowledgements!

Thanks to everyone who has contributed to ack in any way, including
Dan Book,
Tomasz Konojacki,
Salomon Smeke,
M. Scott Ford,
Anders Eriksson,
H.Merijn Brand,
Duke Leto,
Gerhard Poul,
Ethan Mallove,
Marek Kubica,
Ray Donnelly,
Nikolaj Schumacher,
Ed Avis,
Nick Morrott,
Austin Chamberlin,
Varadinsky,
SE<eacute>bastien FeugE<egrave>re,
Jakub Wilk,
Pete Houston,
Stephen Thirlwall,
Jonah Bishop,
Chris Rebert,
Denis Howe,
RaE<uacute>l GundE<iacute>n,
James McCoy,
Daniel Perrett,
Steven Lee,
Jonathan Perret,
Fraser Tweedale,
RaE<aacute>l GundE<aacute>n,
Steffen Jaeckel,
Stephan Hohe,
Michael Beijen,
Alexandr Ciornii,
Christian Walde,
Charles Lee,
Joe McMahon,
John Warwick,
David Steinbrunner,
Kara Martens,
Volodymyr Medvid,
Ron Savage,
Konrad Borowski,
Dale Sedivic,
Michael McClimon,
Andrew Black,
Ralph Bodenner,
Shaun Patterson,
Ryan Olson,
Shlomi Fish,
Karen Etheridge,
Olivier Mengue,
Matthew Wild,
Scott Kyle,
Nick Hooey,
Bo Borgerson,
Mark Szymanski,
Marq Schneider,
Packy Anderson,
JR Boyens,
Dan Sully,
Ryan Niebur,
Kent Fredric,
Mike Morearty,
Ingmar Vanhassel,
Eric Van Dewoestine,
Sitaram Chamarty,
Adam James,
Richard Carlsson,
Pedro Melo,
AJ Schuster,
Phil Jackson,
Michael Schwern,
Jan Dubois,
Christopher J. Madsen,
Matthew Wickline,
David Dyck,
Jason Porritt,
Jjgod Jiang,
Thomas Klausner,
Uri Guttman,
Peter Lewis,
Kevin Riggle,
Ori Avtalion,
Torsten Blix,
Nigel Metheringham,
GE<aacute>bor SzabE<oacute>,
Tod Hagan,
Michael Hendricks,
E<AElig>var ArnfjE<ouml>rE<eth> Bjarmason,
Piers Cawley,
Stephen Steneker,
Elias Lutfallah,
Mark Leighton Fisher,
Matt Diephouse,
Christian Jaeger,
Bill Sully,
Bill Ricker,
David Golden,
Nilson Santos F. Jr,
Elliot Shank,
Merijn Broeren,
Uwe Voelker,
Rick Scott,
Ask BjE<oslash>rn Hansen,
Jerry Gay,
Will Coleda,
Mike O'Regan,
Slaven ReziE<0x107>,
Mark Stosberg,
David Alan Pisoni,
Adriano Ferreira,
James Keenan,
Leland Johnson,
Ricardo Signes,
Pete Krawczyk and
Rob Hoelz.

=head1 AUTHOR

Andy Lester, C<< <andy at petdance.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2005-2020 Andy Lester.

This program is free software; you can redistribute it and/or modify
it under the terms of the Artistic License v2.0.

See https://www.perlfoundation.org/artistic-license-20.html or the LICENSE.md
file that comes with the ack distribution.

=cut

1;
package App::Ack;

use warnings;
use strict;


our $VERSION;
our $COPYRIGHT;
BEGIN {
    $VERSION = 'v3.4.0'; # Check https://beyondgrep.com/ for updates
    $COPYRIGHT = 'Copyright 2005-2020 Andy Lester.';
}
our $STANDALONE = 0;
our $ORIGINAL_PROGRAM_NAME;

our $fh;

BEGIN {
    $fh = *STDOUT;
}


our %types;
our %type_wanted;
our %mappings;
our %ignore_dirs;

our $is_filter_mode;
our $output_to_pipe;

our $is_windows;

our $debug_nopens = 0;

# Line ending, changes to "\0" if --print0.
our $ors = "\n";

BEGIN {
    # These have to be checked before any filehandle diddling.
    $output_to_pipe  = not -t *STDOUT;
    $is_filter_mode = -p STDIN;

    $is_windows      = ($^O eq 'MSWin32');
}


sub warn {
    return CORE::warn( _my_program(), ': ', @_, "\n" );
}


sub die {
    return CORE::die( _my_program(), ': ', @_, "\n" );
}

sub _my_program {
    require File::Basename;
    return File::Basename::basename( $0 );
}


sub thpppt {
    my $y = q{_   /|,\\'!.x',=(www)=,   U   };
    $y =~ tr/,x!w/\nOo_/;

    App::Ack::print( "$y ack $_[0]!\n" );
    exit 0;
}

sub ackbar {
    my $x;
    $x = <<'_BAR';
 6?!I'7!I"?%+!
 3~!I#7#I"7#I!?!+!="+"="+!:!
 2?#I!7!I!?#I!7!I"+"=%+"=#
 1?"+!?*+!=#~"=!+#?"="+!
 0?"+!?"I"?&+!="~!=!~"=!+%="+"
 /I!+!?)+!?!+!=$~!=!~!="+!="+"?!="?!
 .?%I"?%+%='?!=#~$="
 ,,!?%I"?(+$=$~!=#:"~$:!~!
 ,I!?!I!?"I"?!+#?"+!?!+#="~$:!~!:!~!:!,!:!,":#~!
 +I!?&+!="+!?#+$=!~":!~!:!~!:!,!:#,!:!,%:"
 *+!I!?!+$=!+!=!+!?$+#=!~":!~":#,$:",#:!,!:!
 *I!?"+!?!+!=$+!?#+#=#~":$,!:",!:!,&:"
 )I!?$=!~!=#+"?!+!=!+!=!~!="~!:!~":!,'.!,%:!~!
 (=!?"+!?!=!~$?"+!?!+!=#~"=",!="~$,$.",#.!:!=!
 (I"+"="~"=!+&=!~"=!~!,!~!+!=!?!+!?!=!I!?!+"=!.",!.!,":!
 %I$?!+!?!=%+!~!+#~!=!~#:#=!~!+!~!=#:!,%.!,!.!:"
 $I!?!=!?!I!+!?"+!=!~!=!~!?!I!?!=!+!=!~#:",!~"=!~!:"~!=!:",&:" '-/
 $?!+!I!?"+"=!+"~!,!:"+#~#:#,"=!~"=!,!~!,!.",!:".!:! */! !I!t!'!s! !a! !g!r!e!p!!! !/!
 $+"=!+!?!+"~!=!:!~!:"I!+!,!~!=!:!~!,!:!,$:!~".&:"~!,# (-/
 %~!=!~!=!:!.!+"~!:!,!.!,!~!=!:$.!,":!,!.!:!~!,!:!=!.#="~!,!:" ./!
 %=!~!?!+"?"+!=!~",!.!:!?!~!.!:!,!:!,#.!,!:","~!:!=!~!=!:",!~! ./!
 %+"~":!~!=#~!:!~!,!.!~!:",!~!=!~!.!:!,!.",!:!,":!=":!.!,!:!7! -/!
 %~",!:".#:!=!:!,!:"+!:!~!:!.!,!~!,!.#,!.!,$:"~!,":"~!=! */!
 &=!~!=#+!=!~",!.!:",#:#,!.",+:!,!.",!=!+!?!
 &~!=!~!=!~!:"~#:",!.!,#~!:!.!+!,!.",$.",$.#,!+!I!?!
 &~!="~!:!~":!~",!~!=!~":!,!:!~!,!:!,&.$,#."+!?!I!?!I!
 &~!=!~!=!+!,!:!~!:!=!,!:!~&:$,!.!,".!,".!,#."~!+!?$I!
 &~!=!~!="~!=!:!~":!,!~%:#,!:",!.!,#.",#I!7"I!?!+!?"I"
 &+!I!7!:#~"=!~!:!,!:"~$.!=!.!,!~!,$.#,!~!7!I#?!+!?"I"7!
 %7#?!+!~!:!=!~!=!~":!,!:"~":#.!,)7#I"?"I!7&
 %7#I!=":!=!~!:"~$:"~!:#,!:!,!:!~!:#,!7#I!?#7)
 $7$+!,!~!=#~!:!~!:!~$:#,!.!~!:!=!,":!7#I"?#7+=!?!
 $7#I!~!,!~#=!~!:"~!:!,!:!,#:!=!~",":!7$I!?#I!7*+!=!+"
 "I!7$I!,":!,!.!=":$,!:!,$:$7$I!+!?"I!7+?"I!7!I!7!,!
 !,!7%I!:",!."~":!,&.!,!:!~!I!7$I!+!?"I!7,?!I!7',!
 !7(,!.#~":!,%.!,!7%I!7!?#I"7,+!?!7*
7+:!,!~#,"=!7'I!?#I"7/+!7+
77I!+!7!?!7!I"71+!7,
_BAR

    return _pic_decode($x);
}

sub cathy {
    my $x = <<'CATHY';
 0+!--+!
 0|! "C!H!O!C!O!L!A!T!E!!! !|!
 0|! "C!H!O!C!O!L!A!T!E!!! !|!
 0|! "C!H!O!C!O!L!A!T!E!!! !|!
 0|! $A"C!K!!! $|!
 0+!--+!
 6\! 1:!,!.! !
 7\! /.!M!~!Z!M!~!
 8\! /~!D! "M! !
 4.! $\! /M!~!.!8! +.!M# 4
 0,!.! (\! .~!M!N! ,+!I!.!M!.! 3
 /?!O!.!M!:! '\! .O!.! +~!Z!=!N!.! 4
 ..! !D!Z!.!Z!.! '\! 9=!M".! 6
 /.! !.!~!M".! '\! 8~! 9
 4M!.! /.!7!N!M!.! F
 4.! &:!M! !N"M# !M"N!M! #D!M&=! =
 :M!7!M#:! !~!M!7!,!$!M!:! #.! !O!N!.!M!:!M# ;
 8Z!M"~!N!$!D!.!N!?! !I!N!.! (?!M! !M!,!D!M".! 9
 (?!Z!M!N!:! )=!M!O!8!.!M!+!M! !M!,! !O!M! +,!M!.!M!~!Z!N!M!:! &:!~! 0
 &8!7!.!~!M"D!M!,! &M!?!=!8! !M!,!O! !M!+! !+!O!.!M! $M#~! !.!8!M!Z!.!M! !O!M"Z! %:!~!M!Z!M!Z!.! +
 &:!M!7!,! *M!.!Z!M! !8"M!.!M!~! !.!M!.!=! #~!8!.!M! !7!M! "N!Z#I! !D!M!,!M!.! $."M!,! !M!.! *
 2$!O! "N! !.!M!I! !7" "M! "+!O! !~!M! !d!O!.!7!I!M!.! !.!O!=!M!.! !M",!M!.! %.!$!O!D! +
 1~!O! "M!+! !8!$! "M! "?!O! %Z!8!D!M!?!8!I!O!7!M! #M!.!M! "M",!M! 4
 07!~! ".!8! !.!M! "I!+! !.!M! &Z!D!.!7!=!M! !:!.!M! #:!8"+! !.!+!8! !8! 3
 /~!M! #N! !~!M!$! !.!M! !.!M" &~!M! "~!M!O! "D! $M! !8! "M!,!M!+!D!.! 1
 #.! #?!M!N!.! #~!O! $M!.!7!$! "?" !?!~!M! '7!8!?!M!.!+!M"O! $?"$!D! !.!O! !$!7!I!.! 0
 $,!M!:!O!?! ".! !?!=! $=!:!O! !M! "M! !M! !+!$! (.! +.!M! !M!.! !8! !+"Z!~! $:!M!$! !.! '
 #.!8!.!I!$! $7!I! %M" !=!M! !~!M!D! "7!I! .I!O! %?!=!,!D! !,!M! !D!~!8!~! %D!M! (
 #.!M"?! $=!O! %=!N! "8!.! !Z!M! #M!~! (M!:! #.!M" &O! !M!.! !?!,! !8!.!N!~! $8!N!M!,!.! %
 *$!O! &M!,! "O! !.!M!.! #M! (~!M( &O!.! !7! "M! !.!M!.!M!,! #.!M! !M! &
 )=!8!.! $.!M!O!.! "$!.!I!N! !I!M# (7!M(I! %D"Z!M! "=!I! "M! !M!:! #~!D! '
 )D! &8!N!:! ".!O! !M!="M! "M! (7!M) %." !M!D!."M!.! !$!=! !M!,! +
 (M! &+!.!M! #Z!7!O!M!.!~!8! +,!M#D!?!M#D! #.!Z!M#,!Z!?! !~!N! "N!.! !M! +
 'D!:! %$!D! !?! #M!Z! !8!.! !M"?!7!?!7! '+!I!D! !?!O!:!M!:! ":!M!:! !M!7".!M! "8!+! !:!D! !.!M! *
 %.!O!:! $.!O!+! !D!.! #M! "M!.!+!N!I!Z! "7!M!N!M!N!?!I!7!Z!=!M'D"~! #M!.!8!$! !:! !.!M! "N!?! !,!O! )
 !.!?!M!:!M!I! %8!,! "M!.! #M! "N! !M!.! !M!.! !+!~! !.!M!.! ':!M! $M! $M!Z!$! !M!.! "D! "M! "?!M! (
 !7!8! !+!I! ".! "$!=! ":!$! "+! !M!.! !O! !M!I!M".! !=!~! ",!O! '=!M! $$!,! #N!:! ":!8!.! !D!~! !,!M!.! !:!M!.! &
 !:!,!.! &Z" #D! !.!8!."M!.! !8!?!Z!M!.!M! #Z!~! !?!M!Z!.! %~!O!.!8!$!N!8!O!I!:!~! !+! #M!.! !.!M!.! !+!M! ".!~!M!+! $
 !.! 'D!I! #?!M!.!M!,! !.!Z! !.!8! #M&O!I!?! (~!I!M"." !M!Z!.! !M!N!.! "+!$!.! "M!.! !M!?!.! "8!M! $
 (O!8! $M! !M!.! ".!:! !+!=! #M! #.!M! !+" *$!M":!.! !M!~! "M!7! #M! #7!Z! "M"$!M!.! !.! #
 '$!Z! #.!7!+!M! $.!,! !+!:! #N! #.!M!.!+!M! +D!M! #=!N! ":!O! #=!M! #Z!D! $M!I! %
 $,! ".! $.!M" %$!.! !?!~! "+!7!." !.!M!,! !M! *,!N!M!.$M!?! "D!,! #M!.! #N! +
 ,M!Z! &M! "I!,! "M! %I!M! !?!=!.! (Z!8!M! $:!M!.! !,!M! $D! #.!M!.! )
 +8!O! &.!8! "I!,! !~!M! &N!M! !M!D! '?!N!O!." $?!7! "?!~! #M!.! #I!D!.! (
 3M!,! "N!.! !D" &.!+!M!.! !M":!.":!M!7!M!D! 'M!.! "M!.! "M!,! $I! )
 3I! #M! "M!,! !:! &.!M" ".!,! !.!$!M!I! #.! !:! !.!M!?! "N!+! ".! /
 1M!,! #.!M!8!M!=!.! +~!N"O!Z"~! *+!M!.! "M! 2
 0.!M! &M!.! 8:! %.!M!Z! "M!=! *O!,! %
 0?!$! &N! )." .,! %."M! ":!M!.! 0
 0N!:! %?!O! #.! ..! &,! &.!D!,! "N!I! 0
CATHY
    return _pic_decode($x);
}

sub _pic_decode {
    my($compressed) = @_;
    $compressed =~ s/(.)(.)/$1x(ord($2)-32)/eg;
    App::Ack::print( $compressed );
    exit 0;
}


sub show_help {
    App::Ack::print( <<"END_OF_HELP" );
Usage: ack [OPTION]... PATTERN [FILES OR DIRECTORIES]

Search for PATTERN in each source file in the tree from the current
directory on down.  If any files or directories are specified, then
only those files and directories are checked.  ack may also search
STDIN, but only if no file or directory arguments are specified,
or if one of them is "-".

Default switches may be specified in an .ackrc file. If you want no dependency
on the environment, turn it off with --noenv.

File select actions:
  -f                            Only print the files selected, without
                                searching.  The PATTERN must not be specified.
  -g                            Same as -f, but only select files matching
                                PATTERN.

File listing actions:
  -l, --files-with-matches      Print filenames with at least one match
  -L, --files-without-matches   Print filenames with no matches
  -c, --count                   Print filenames and count of matching lines

Searching:
  -i, --ignore-case             Ignore case distinctions in PATTERN
  -S, --[no]smart-case          Ignore case distinctions in PATTERN,
                                only if PATTERN contains no upper case.
                                Ignored if -i or -I are specified.
  -I, --no-ignore-case          Turns on case-sensitivity in PATTERN.
                                Negates -i and --smart-case.
  -v, --invert-match            Invert match: select non-matching lines
  -w, --word-regexp             Force PATTERN to match only whole words
  -Q, --literal                 Quote all metacharacters; PATTERN is literal
  --range-start PATTERN         Specify PATTERN as the start of a match range.
  --range-end PATTERN           Specify PATTERN as the end of a match range.
  --match PATTERN               Specify PATTERN explicitly. Typically omitted.

Search output:
  --output=expr                 Output the evaluation of expr for each line
                                (turns off text highlighting)
  -o                            Show only the part of a line matching PATTERN
                                Same as --output='\$&'
  --passthru                    Print all lines, whether matching or not
  -m, --max-count=NUM           Stop searching in each file after NUM matches
  -1                            Stop searching after one match of any kind
  -H, --with-filename           Print the filename for each match (default:
                                on unless explicitly searching a single file)
  -h, --no-filename             Suppress the prefixing filename on output
  --[no]column                  Show the column number of the first match

  -A NUM, --after-context=NUM   Print NUM lines of trailing context after
                                matching lines.
  -B NUM, --before-context=NUM  Print NUM lines of leading context before
                                matching lines.
  -C [NUM], --context[=NUM]     Print NUM lines (default 2) of output context.

  --print0                      Print null byte as separator between filenames,
                                only works with -f, -g, -l, -L or -c.

  -s                            Suppress error messages about nonexistent or
                                unreadable files.


File presentation:
  --pager=COMMAND               Pipes all ack output through COMMAND.  For
                                example, --pager="less -R".  Ignored if output
                                is redirected.
  --nopager                     Do not send output through a pager.  Cancels
                                any setting in ~/.ackrc, ACK_PAGER or
                                ACK_PAGER_COLOR.
  --[no]heading                 Print a filename heading above each file's
                                results.  (default: on when used interactively)
  --[no]break                   Print a break between results from different
                                files.  (default: on when used interactively)
  --group                       Same as --heading --break
  --nogroup                     Same as --noheading --nobreak
  -p, --proximate=LINES         Separate match output with blank lines unless
                                they are within LINES lines from each other.
  -P, --proximate=0             Negates --proximate.
  --[no]underline               Print a line of carets under the matched text.
  --[no]color, --[no]colour     Highlight the matching text (default: on unless
                                output is redirected, or on Windows)
  --color-filename=COLOR
  --color-match=COLOR
  --color-colno=COLOR
  --color-lineno=COLOR          Set the color for filenames, matches, line and
                                column numbers.
  --help-colors                 Show a list of possible color combinations.
  --help-rgb-colors             Show a list of advanced RGB colors.
  --flush                       Flush output immediately, even when ack is used
                                non-interactively (when output goes to a pipe or
                                file).


File finding:
  --sort-files                  Sort the found files lexically.
  --show-types                  Show which types each file has.
  --files-from=FILE             Read the list of files to search from FILE.
  -x                            Read the list of files to search from STDIN.

File inclusion/exclusion:
  --[no]ignore-dir=name         Add/remove directory from list of ignored dirs
  --[no]ignore-directory=name   Synonym for ignore-dir
  --ignore-file=FILTER:ARGS     Add filter for ignoring files.
  -r, -R, --recurse             Recurse into subdirectories (default: on)
  -n, --no-recurse              No descending into subdirectories
  --[no]follow                  Follow symlinks.  Default is off.

File type inclusion/exclusion:
  -t X, --type=X                Include only X files, where X is a filetype,
                                e.g. python, html, markdown, etc
  -T X, --type=noX              Exclude X files, where X is a filetype.
  -k, --known-types             Include only files of types that ack recognizes.
  --help-types                  Display all known types, and how they're defined.

File type specification:
  --type-set=TYPE:FILTER:ARGS   Files with the given ARGS applied to the given
                                FILTER are recognized as being of type TYPE.
                                This replaces an existing definition for TYPE.
  --type-add=TYPE:FILTER:ARGS   Files with the given ARGS applied to the given
                                FILTER are recognized as being type TYPE.
  --type-del=TYPE               Removes all filters associated with TYPE.

Miscellaneous:
  --version                     Display version & copyright
  --[no]env                     Ignore environment variables and global ackrc
                                files.  --env is legal but redundant.
  --ackrc=filename              Specify an ackrc file to use
  --ignore-ack-defaults         Ignore default definitions included with ack.
  --create-ackrc                Outputs a default ackrc for your customization
                                to standard output.
  --dump                        Dump information on which options are loaded
                                and where they're defined.
  --[no]filter                  Force ack to treat standard input as a pipe
                                (--filter) or tty (--nofilter)
  --help                        This help
  --man                         Print the manual.
  --help-types                  Display all known types, and how they're defined.
  --help-colors                 Show a list of possible color combinations.
  --help-rgb-colors             Show a list of advanced RGB colors.
  --thpppt                      Bill the Cat
  --bar                         The warning admiral
  --cathy                       Chocolate! Chocolate! Chocolate!

Filter specifications:
    If FILTER is "ext", ARGS is a list of extensions checked against the
        file's extension.
    If FILTER is "is", ARGS must match the file's name exactly.
    If FILTER is "match", ARGS is matched as a case-insensitive regex
        against the filename.
    If FILTER is "firstlinematch", ARGS is matched as a regex the first
        line of the file's contents.

Exit status is 0 if match, 1 if no match.

ack's home page is at https://beyondgrep.com/

The full ack manual is available by running "ack --man".

This is version $App::Ack::VERSION of ack.  Run "ack --version" for full version info.
END_OF_HELP

    return;
 }



sub show_help_types {
    App::Ack::print( <<'END_OF_HELP' );
Usage: ack [OPTION]... PATTERN [FILES OR DIRECTORIES]

The following is the list of filetypes supported by ack.  You can specify a
filetype to include with -t TYPE or --type=TYPE.  You can exclude a
filetype with -T TYPE or --type=noTYPE.

Note that some files may appear in multiple types.  For example, a file
called Rakefile is both Ruby (--type=ruby) and Rakefile (--type=rakefile).

END_OF_HELP

    my @types = keys %App::Ack::mappings;
    my $maxlen = 0;
    for ( @types ) {
        $maxlen = length if $maxlen < length;
    }
    for my $type ( sort @types ) {
        next if $type =~ /^-/; # Stuff to not show
        my $ext_list = $mappings{$type};

        if ( ref $ext_list ) {
            $ext_list = join( '; ', map { $_->to_string } @{$ext_list} );
        }
        App::Ack::print( sprintf( "    %-*.*s %s\n", $maxlen, $maxlen, $type, $ext_list ) );
    }

    return;
}



sub show_help_colors {
    App::Ack::print( <<'END_OF_HELP' );
ack allows customization of the colors it uses when presenting matches
onscreen.  See the "ACK COLORS" section of the ack manual (ack --man).

Here is a chart of how various color combinations appear: Each of the eight
foreground colors, on each of the eight background colors or no background
color, with and without the bold modifier.

Run ack --help-rgb-colors for a chart of the RGB colors.

END_OF_HELP

    _show_color_grid();

    return;
}



sub show_help_rgb {
    App::Ack::print( <<'END_OF_HELP' );
ack allows customization of the colors it uses when presenting matches
onscreen.  See the "ACK COLORS" section of the ack manual (ack --man).

Colors may be specified as "rggNNN" where "NNN" is a triplet of digits
from 0 to 5 specifying the intensity of red, green and blue, respectively.

Here is a grid of the 216 possible values for NNN.

END_OF_HELP

    _show_rgb_grid();

    App::Ack::say( 'Here are the 216 possible colors with the "reverse" modifier applied.', "\n" );

    _show_rgb_grid( 'reverse' );

    return;
}


sub _show_color_grid {
    my $cell_width = 7;

    my @fg_colors = qw( black red green yellow blue magenta cyan white );
    my @bg_colors = map { "on_$_" } @fg_colors;

    App::Ack::say(
        _color_cell( '' ),
        map { _color_cell( $_ ) } @fg_colors
    );

    App::Ack::say(
        _color_cell( '' ),
        map { _color_cell( '-' x $cell_width ) } @fg_colors
    );

    for my $bg ( '', @bg_colors ) {
        App::Ack::say(
            _color_cell( '' ),
            ( map { _color_cell( $_, "$_ $bg" ) } @fg_colors ),
            $bg
        );

        App::Ack::say(
            _color_cell( 'bold' ),
            ( map { _color_cell( $_, "bold $_ $bg" ) } @fg_colors ),
            $bg
        );
        App::Ack::say();
    }

    return;
}


sub _color_cell {
    my $text  = shift;
    my $color = shift;

    my $cell_width = 7;
    $text = sprintf( '%-*s', $cell_width, $text );

    return ($color ? Term::ANSIColor::colored( $text, $color ) : $text) . ' ';
}


sub _show_rgb_grid {
    my $modifier = shift // '';

    my $grid = <<'HERE';
544 544 544 544 544 554 554 554 554 554 454 454 454 454 454 455 455 455 455 455 445 445 445 445 445 545 545 545 545 545
533 533 533 543 543 553 553 553 453 453 353 353 353 354 354 355 355 355 345 345 335 335 335 435 435 535 535 535 534 534
511 521 531 531 541 551 451 451 351 251 151 152 152 153 154 155 145 145 135 125 115 215 215 315 415 515 514 514 513 512
500 510 520 530 540 550 450 350 250 150 050 051 052 053 054 055 045 035 025 015 005 105 205 305 405 505 504 503 502 501
400 410 410 420 430 440 340 340 240 140 040 041 041 042 043 044 034 034 024 014 004 104 104 204 304 404 403 403 402 401
300 300 310 320 320 330 330 230 130 130 030 030 031 032 032 033 033 023 013 013 003 003 103 203 203 303 303 302 301 301
200 200 200 210 210 220 220 220 120 120 020 020 020 021 021 022 022 022 012 012 002 002 002 102 102 202 202 202 201 201
100 100 100 100 100 110 110 110 110 110 010 010 010 010 010 011 011 011 011 011 001 001 001 001 001 101 101 101 101 101

522 522 532 542 542 552 552 452 352 352 252 252 253 254 254 255 255 245 235 235 225 225 325 425 425 525 525 524 523 523

411 411 421 431 431 441 441 341 241 241 141 141 142 143 143 144 144 134 124 124 114 114 214 314 314 414 414 413 412 412

422 422 432 432 432 442 442 442 342 342 242 242 242 243 243 244 244 244 234 234 224 224 224 324 324 424 424 424 423 423

311 311 311 321 321 331 331 331 231 231 131 131 131 132 132 133 133 133 123 123 113 113 113 213 213 313 313 313 312 312

433 433 433 433 433 443 443 443 443 443 343 343 343 343 343 344 344 344 344 344 334 334 334 334 334 434 434 434 434 434
211 211 211 211 211 221 221 221 221 221 121 121 121 121 121 122 122 122 122 122 112 112 112 112 112 212 212 212 212 212

322 322 322 322 322 332 332 332 332 332 232 232 232 232 232 233 233 233 233 233 223 223 223 223 223 323 323 323 323 323

555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555 555
444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444 444
333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333 333
222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222 222
111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111 111
000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000
HERE

    $grid =~ s/(\d\d\d)/Term::ANSIColor::colored( "$1", "$modifier rgb$1" )/eg;

    App::Ack::say( $grid );

    return;
}


sub show_man {
    require Pod::Usage;
    Pod::Usage::pod2usage({
        -input   => $App::Ack::ORIGINAL_PROGRAM_NAME,
        -verbose => 2,
        -exitval => 0,
    });

    return;
}



sub get_version_statement {
    require Config;

    my $copyright = $App::Ack::COPYRIGHT;
    my $this_perl = $Config::Config{perlpath};
    if ($^O ne 'VMS') {
        my $ext = $Config::Config{_exe};
        $this_perl .= $ext unless $this_perl =~ m/$ext$/i;
    }
    my $perl_ver = sprintf( 'v%vd', $^V );

    my $build_type = $App::Ack::STANDALONE ? 'standalone version' : 'standard build';

    return <<"END_OF_VERSION";
ack $App::Ack::VERSION ($build_type)
Running under Perl $perl_ver at $this_perl

$copyright

This program is free software.  You may modify or distribute it
under the terms of the Artistic License v2.0.
END_OF_VERSION
}


sub print            { print {$fh} @_; return; }
sub say              { print {$fh} @_, $ors; return; }
sub print_blank_line { print {$fh} "\n"; return; }

sub set_up_pager {
    my $command = shift;

    return if App::Ack::output_to_pipe();

    my $pager;
    if ( not open( $pager, '|-', $command ) ) {
        App::Ack::die( qq{Unable to pipe to pager "$command": $!} );
    }
    $fh = $pager;

    return;
}


sub output_to_pipe {
    return $output_to_pipe;
}


sub exit_from_ack {
    my $nmatches = shift;

    my $rc = $nmatches ? 0 : 1;
    exit $rc;
}


sub show_types {
    my $file = shift;

    my @types = filetypes( $file );
    my $arrow = @types ? ' => ' : ' =>';
    App::Ack::say( $file->name, $arrow, join( ',', @types ) );

    return;
}


sub filetypes {
    my ( $file ) = @_;

    my @matches;

    foreach my $k (keys %App::Ack::mappings) {
        my $filters = $App::Ack::mappings{$k};

        foreach my $filter (@{$filters}) {
            # Clone the file.
            my $clone = $file->clone;
            if ( $filter->filter($clone) ) {
                push @matches, $k;
                last;
            }
        }
    }

    # https://metacpan.org/pod/distribution/Perl-Critic/lib/Perl/Critic/Policy/Subroutines/ProhibitReturnSort.pm
    @matches = sort @matches;
    return @matches;
}


sub is_lowercase {
    my $pat = shift;

    # The simplest case.
    return 1 if lc($pat) eq $pat;

    # If we have capitals, then go clean up any metacharacters that might have capitals.

    # Get rid of any literal backslashes first to avoid confusion.
    $pat =~ s/\\\\//g;

    my $metacharacter = qr/
        |\\A                # Beginning of string
        |\\B                # Not word boundary
        |\\c[a-zA-Z]        # Control characters
        |\\D                # Non-digit character
        |\\G                # End-of-match position of prior match
        |\\H                # Not horizontal whitespace
        |\\K                # Keep to the left
        |\\N(\{.+?\})?      # Anything but \n, OR Unicode sequence
        |\\[pP]\{.+?\}      # Named property and negation
        |\\[pP][A-Z]        # Named property and negation, single-character shorthand
        |\\R                # Linebreak
        |\\S                # Non-space character
        |\\V                # Not vertical whitespace
        |\\W                # Non-word character
        |\\X                # ???
        |\\x[0-9A-Fa-f]{2}  # Hex sequence
        |\\Z                # End of string
    /x;
    $pat =~ s/$metacharacter//g;

    my $name = qr/[_A-Za-z][_A-Za-z0-9]*?/;
    # Eliminate named captures.
    $pat =~ s/\(\?'$name'//g;
    $pat =~ s/\(\?<$name>//g;

    # Eliminate named backreferences.
    $pat =~ s/\\k'$name'//g;
    $pat =~ s/\\k<$name>//g;
    $pat =~ s/\\k\{$name\}//g;

    # Now with those metacharacters and named things removed, now see if it's lowercase.
    return 1 if lc($pat) eq $pat;

    return 0;
}


1; # End of App::Ack
package App::Ack::ConfigDefault;

use warnings;
use strict;




sub options {
    return split( /\n/, _options_block() );
}


sub options_clean {
    return grep { /./ && !/^#/ } options();
}


sub _options_block {
    my $lines = <<'HERE';
# This is the default ackrc for ack version ==VERSION==.

# There are four different ways to match
#
# is:  Match the filename exactly
#
# ext: Match the extension of the filename exactly
#
# match: Match the filename against a Perl regular expression
#
# firstlinematch: Match the first 250 characters of the first line
#   of text against a Perl regular expression.  This is only for
#   the --type-add option.


### Directories to ignore

# Bazaar
# https://bazaar.canonical.com/
--ignore-directory=is:.bzr

# Codeville
# http://freshmeat.sourceforge.net/projects/codeville
--ignore-directory=is:.cdv

# Interface Builder (Xcode)
# https://en.wikipedia.org/wiki/Interface_Builder
--ignore-directory=is:~.dep
--ignore-directory=is:~.dot
--ignore-directory=is:~.nib
--ignore-directory=is:~.plst

# Git
# https://git-scm.com/
--ignore-directory=is:.git
# When submodules are used, .git is a file.
--ignore-file=is:.git

# Mercurial
# https://www.mercurial-scm.org/
--ignore-directory=is:.hg

# Quilt
# https://directory.fsf.org/wiki/Quilt
--ignore-directory=is:.pc

# Subversion
# https://subversion.apache.org/
--ignore-directory=is:.svn

# Monotone
# https://www.monotone.ca/
--ignore-directory=is:_MTN

# CVS
# https://savannah.nongnu.org/projects/cvs
--ignore-directory=is:CVS

# RCS
# https://www.gnu.org/software/rcs/
--ignore-directory=is:RCS

# SCCS
# https://en.wikipedia.org/wiki/Source_Code_Control_System
--ignore-directory=is:SCCS

# darcs
# http://darcs.net/
--ignore-directory=is:_darcs

# Vault/Fortress
--ignore-directory=is:_sgbak

# autoconf
# https://www.gnu.org/software/autoconf/
--ignore-directory=is:autom4te.cache

# Perl module building
--ignore-directory=is:blib
--ignore-directory=is:_build

# Perl Devel::Cover module's output directory
# https://metacpan.org/release/Devel-Cover
--ignore-directory=is:cover_db

# Node modules created by npm
--ignore-directory=is:node_modules

# CMake cache
# https://www.cmake.org/
--ignore-directory=is:CMakeFiles

# Eclipse workspace folder
# https://eclipse.org/
--ignore-directory=is:.metadata

# Cabal (Haskell) sandboxes
# https://www.haskell.org/cabal/users-guide/installing-packages.html
--ignore-directory=is:.cabal-sandbox

# Python caches
# https://docs.python.org/3/tutorial/modules.html
--ignore-directory=is:__pycache__
--ignore-directory=is:.pytest_cache

# macOS Finder remnants
--ignore-directory=is:__MACOSX
--ignore-file=is:.DS_Store

### Files to ignore

# Backup files
--ignore-file=ext:bak
--ignore-file=match:/~$/

# Emacs swap files
--ignore-file=match:/^#.+#$/

# vi/vim swap files https://www.vim.org/
--ignore-file=match:/[._].*[.]swp$/

# core dumps
--ignore-file=match:/core[.]\d+$/

# minified Javascript
--ignore-file=match:/[.-]min[.]js$/
--ignore-file=match:/[.]js[.]min$/

# minified CSS
--ignore-file=match:/[.]min[.]css$/
--ignore-file=match:/[.]css[.]min$/

# JS and CSS source maps
--ignore-file=match:/[.]js[.]map$/
--ignore-file=match:/[.]css[.]map$/

# PDFs, because they pass Perl's -T detection
--ignore-file=ext:pdf

# Common graphics, just as an optimization
--ignore-file=ext:gif,jpg,jpeg,png

# Common archives, as an optimization
--ignore-file=ext:gz,tar,tgz,zip

# Python compiles modules
--ignore-file=ext:pyc,pyd,pyo

# C extensions
--ignore-file=ext:so

# Compiled gettext files
--ignore-file=ext:mo

### Filetypes defined

# Makefiles
# https://www.gnu.org/s/make/
--type-add=make:ext:mk
--type-add=make:ext:mak
--type-add=make:is:makefile
--type-add=make:is:Makefile
--type-add=make:is:Makefile.Debug
--type-add=make:is:Makefile.Release
--type-add=make:is:GNUmakefile

# Rakefiles
# https://rake.rubyforge.org/
--type-add=rake:is:Rakefile

# CMake
# https://cmake.org/
--type-add=cmake:is:CMakeLists.txt
--type-add=cmake:ext:cmake

# Actionscript
--type-add=actionscript:ext:as,mxml

# Ada
# https://www.adaic.org/
--type-add=ada:ext:ada,adb,ads

# ASP
# https://docs.microsoft.com/en-us/previous-versions/office/developer/server-technologies/aa286483(v=msdn.10)
--type-add=asp:ext:asp

# ASP.Net
# https://dotnet.microsoft.com/apps/aspnet
--type-add=aspx:ext:master,ascx,asmx,aspx,svc

# Assembly
--type-add=asm:ext:asm,s

# DOS/Windows batch
--type-add=batch:ext:bat,cmd

# ColdFusion
# https://en.wikipedia.org/wiki/ColdFusion
--type-add=cfmx:ext:cfc,cfm,cfml

# Clojure
# https://clojure.org/
--type-add=clojure:ext:clj,cljs,edn,cljc

# C
# .xs are Perl C files
--type-add=cc:ext:c,h,xs

# C header files
--type-add=hh:ext:h

# CoffeeScript
# https://coffeescript.org/
--type-add=coffeescript:ext:coffee

# C++
--type-add=cpp:ext:cpp,cc,cxx,m,hpp,hh,h,hxx

# C++ header files
--type-add=hpp:ext:hpp,hh,h,hxx

# C#
--type-add=csharp:ext:cs

# CSS
# https://www.w3.org/Style/CSS/
--type-add=css:ext:css

# Dart
# https://dart.dev/
--type-add=dart:ext:dart

# Delphi
# https://en.wikipedia.org/wiki/Embarcadero_Delphi
--type-add=delphi:ext:pas,int,dfm,nfm,dof,dpk,dproj,groupproj,bdsgroup,bdsproj

# Elixir
# https://elixir-lang.org/
--type-add=elixir:ext:ex,exs

# Emacs Lisp
# https://www.gnu.org/software/emacs
--type-add=elisp:ext:el

# Erlang
# https://www.erlang.org/
--type-add=erlang:ext:erl,hrl

# Fortran
# https://en.wikipedia.org/wiki/Fortran
--type-add=fortran:ext:f,f77,f90,f95,f03,for,ftn,fpp

# Go
# https://golang.org/
--type-add=go:ext:go

# Groovy
# https://www.groovy-lang.org/
--type-add=groovy:ext:groovy,gtmpl,gpp,grunit,gradle

# GSP
# https://gsp.grails.org/
--type-add=gsp:ext:gsp

# Haskell
# https://www.haskell.org/
--type-add=haskell:ext:hs,lhs

# HTML
--type-add=html:ext:htm,html,xhtml

# Jade
# http://jade-lang.com/
--type-add=jade:ext:jade

# Java
# https://www.oracle.com/technetwork/java/index.html
--type-add=java:ext:java,properties

# JavaScript
--type-add=js:ext:js

# JSP
# https://www.oracle.com/technetwork/java/javaee/jsp/index.html
--type-add=jsp:ext:jsp,jspx,jspf,jhtm,jhtml

# JSON
# https://json.org/
--type-add=json:ext:json

# Kotlin
# https://kotlinlang.org/
--type-add=kotlin:ext:kt,kts

# Less
# http://www.lesscss.org/
--type-add=less:ext:less

# Common Lisp
# https://common-lisp.net/
--type-add=lisp:ext:lisp,lsp

# Lua
# https://www.lua.org/
--type-add=lua:ext:lua
--type-add=lua:firstlinematch:/^#!.*\blua(jit)?/

# Markdown
# https://en.wikipedia.org/wiki/Markdown
--type-add=markdown:ext:md,markdown
# We understand that there are many ad hoc extensions for markdown
# that people use.  .md and .markdown are the two that ack recognizes.
# You are free to add your own in your ackrc file.

# Matlab
# https://en.wikipedia.org/wiki/MATLAB
--type-add=matlab:ext:m

# Objective-C
--type-add=objc:ext:m,h

# Objective-C++
--type-add=objcpp:ext:mm,h

# OCaml
# https://ocaml.org/
--type-add=ocaml:ext:ml,mli,mll,mly

# Perl
# https://perl.org/
--type-add=perl:ext:pl,pm,pod,t,psgi
--type-add=perl:firstlinematch:/^#!.*\bperl/

# Perl tests
--type-add=perltest:ext:t

# Perl's Plain Old Documentation format, POD
--type-add=pod:ext:pod

# PHP
# https://www.php.net/
--type-add=php:ext:php,phpt,php3,php4,php5,phtml
--type-add=php:firstlinematch:/^#!.*\bphp/

# Plone
# https://plone.org/
--type-add=plone:ext:pt,cpt,metadata,cpy,py

# Python
# https://www.python.org/
--type-add=python:ext:py
--type-add=python:firstlinematch:/^#!.*\bpython/

# R
# https://www.r-project.org/
--type-add=rr:ext:R

# reStructured Text
# https://docutils.sourceforge.io/rst.html
--type-add=rst:ext:rst

# Ruby
# https://www.ruby-lang.org/
--type-add=ruby:ext:rb,rhtml,rjs,rxml,erb,rake,spec
--type-add=ruby:is:Rakefile
--type-add=ruby:firstlinematch:/^#!.*\bruby/

# Rust
# https://www.rust-lang.org/
--type-add=rust:ext:rs

# Sass
# https://sass-lang.com
--type-add=sass:ext:sass,scss

# Scala
# https://www.scala-lang.org/
--type-add=scala:ext:scala

# Scheme
# https://groups.csail.mit.edu/mac/projects/scheme/
--type-add=scheme:ext:scm,ss

# Shell
--type-add=shell:ext:sh,bash,csh,tcsh,ksh,zsh,fish
--type-add=shell:firstlinematch:/^#!.*\b(?:ba|t?c|k|z|fi)?sh\b/

# Smalltalk
# http://www.smalltalk.org/
--type-add=smalltalk:ext:st

# Smarty
# https://www.smarty.net/
--type-add=smarty:ext:tpl

# SQL
# https://www.iso.org/standard/45498.html
--type-add=sql:ext:sql,ctl

# Stylus
# http://stylus-lang.com/
--type-add=stylus:ext:styl

# SVG
# https://en.wikipedia.org/wiki/Scalable_Vector_Graphics
--type-add=svg:ext:svg

# Swift
# https://developer.apple.com/swift/
--type-add=swift:ext:swift
--type-add=swift:firstlinematch:/^#!.*\bswift/

# Tcl
# https://www.tcl.tk/
--type-add=tcl:ext:tcl,itcl,itk

# TeX & LaTeX
# https://www.latex-project.org/
--type-add=tex:ext:tex,cls,sty

# Template Toolkit (Perl)
# http//template-toolkit.org/
--type-add=ttml:ext:tt,tt2,ttml

# TOML
# https://toml.io/
--type-add=toml:ext:toml

# Typescript
# https://www.typescriptlang.org/
--type-add=ts:ext:ts,tsx

# Visual Basic
--type-add=vb:ext:bas,cls,frm,ctl,vb,resx

# Verilog
--type-add=verilog:ext:v,vh,sv

# VHDL
# http://www.eda.org/twiki/bin/view.cgi/P1076/WebHome
--type-add=vhdl:ext:vhd,vhdl

# Vim
# https://www.vim.org/
--type-add=vim:ext:vim

# XML
# https://www.w3.org/TR/REC-xml/
--type-add=xml:ext:xml,dtd,xsd,xsl,xslt,ent,wsdl
--type-add=xml:firstlinematch:/<[?]xml/

# YAML
# https://yaml.org/
--type-add=yaml:ext:yaml,yml
HERE
    $lines =~ s/==VERSION==/$App::Ack::VERSION/sm;

    return $lines;
}

1;
package App::Ack::ConfigFinder;


use strict;
use warnings;

use Cwd 3.00 ();
use File::Spec 3.00 ();

use if ($^O eq 'MSWin32'), 'Win32';


sub new {
    my ( $class ) = @_;

    return bless {}, $class;
}


sub _remove_redundancies {
    my @configs = @_;

    my %seen;
    my @uniq;
    foreach my $config (@configs) {
        my $path = $config->{path};
        my $key = -e $path ? Cwd::realpath( $path ) : $path;
        if ( not $App::Ack::is_windows ) {
            # On Unix, uniquify on inode.
            my ($dev, $inode) = (stat $key)[0, 1];
            $key = "$dev:$inode" if defined $dev;
        }
        push( @uniq, $config ) unless $seen{$key}++;
    }
    return @uniq;
}


sub _check_for_ackrc {
    return unless defined $_[0];

    my @files = grep { -f }
                map { File::Spec->catfile(@_, $_) }
                qw(.ackrc _ackrc);

    App::Ack::die( File::Spec->catdir(@_) . ' contains both .ackrc and _ackrc. Please remove one of those files.' )
        if @files > 1;

    return wantarray ? @files : $files[0];
} # end _check_for_ackrc



sub find_config_files {
    my @config_files;

    if ( $App::Ack::is_windows ) {
        push @config_files, map { +{ path => File::Spec->catfile($_, 'ackrc') } } (
            Win32::GetFolderPath(Win32::CSIDL_COMMON_APPDATA()),
            Win32::GetFolderPath(Win32::CSIDL_APPDATA()),
        );
    }
    else {
        push @config_files, { path => '/etc/ackrc' };
    }


    if ( $ENV{'ACKRC'} && -f $ENV{'ACKRC'} ) {
        push @config_files, { path => $ENV{'ACKRC'} };
    }
    else {
        push @config_files, map { +{ path => $_ } } _check_for_ackrc($ENV{'HOME'});
    }

    my $cwd = Cwd::getcwd();
    return () unless defined $cwd;

    # XXX This should go through some untainted cwd-fetching function, and not get untainted brute-force like this.
    $cwd =~ /(.+)/;
    $cwd = $1;
    my @dirs = File::Spec->splitdir( $cwd );
    while ( @dirs ) {
        my $ackrc = _check_for_ackrc(@dirs);
        if ( defined $ackrc ) {
            push @config_files, { project => 1, path => $ackrc };
            last;
        }
        pop @dirs;
    }

    # We only test for existence here, so if the file is deleted out from under us, this will fail later.
    return _remove_redundancies( @config_files );
}

1;
package App::Ack::ConfigLoader;

use strict;
use warnings;
use 5.010;

use File::Spec 3.00 ();
use Getopt::Long 2.39 ();
use Text::ParseWords 3.1 ();

sub opt_parser {
    my @opts = @_;

    my @standard = qw(
        default
        bundling
        no_auto_help
        no_auto_version
        no_ignore_case
    );
    return Getopt::Long::Parser->new( config => [ @standard, @opts ] );
}

sub _generate_ignore_dir {
    my ( $option_name, $opt ) = @_;

    my $is_inverted = $option_name =~ /^--no/;

    return sub {
        my ( undef, $dir ) = @_;

        $dir = _remove_directory_separator( $dir );
        if ( $dir !~ /:/ ) {
            $dir = 'is:' . $dir;
        }

        my ( $filter_type, $args ) = split /:/, $dir, 2;

        if ( $filter_type eq 'firstlinematch' ) {
            App::Ack::die( qq{Invalid filter specification "$filter_type" for option '$option_name'} );
        }

        my $filter = App::Ack::Filter->create_filter($filter_type, split(/,/, $args));
        my $collection;

        my $previous_inversion_matches = $opt->{idirs} && !($is_inverted xor $opt->{idirs}[-1]->is_inverted());

        if ( $previous_inversion_matches ) {
            $collection = $opt->{idirs}[-1];

            if ( $is_inverted ) {
                # This relies on invert of an inverted filter to return the original.
                $collection = $collection->invert();
            }
        }
        else {
            $collection = App::Ack::Filter::Collection->new();
            push @{ $opt->{idirs} }, $is_inverted ? $collection->invert() : $collection;
        }

        $collection->add($filter);

        if ( $filter_type eq 'is' ) {
            $collection->add(App::Ack::Filter::IsPath->new($args));
        }
    };
}


sub _remove_directory_separator {
    my $path = shift;

    state $dir_sep_chars = $App::Ack::is_windows ? quotemeta( '\\/' ) : quotemeta( File::Spec->catfile( '', '' ) );

    $path =~ s/[$dir_sep_chars]$//;

    return $path;
}


sub _process_filter_spec {
    my ( $spec ) = @_;

    if ( $spec =~ /^(\w+):(\w+):(.*)/ ) {
        my ( $type_name, $ext_type, $arguments ) = ( $1, $2, $3 );

        return ( $type_name,
            App::Ack::Filter->create_filter($ext_type, split(/,/, $arguments)) );
    }
    elsif ( $spec =~ /^(\w+)=(.*)/ ) { # Check to see if we have ack1-style argument specification.
        my ( $type_name, $extensions ) = ( $1, $2 );

        my @extensions = split(/,/, $extensions);
        foreach my $extension ( @extensions ) {
            $extension =~ s/^[.]//;
        }

        return ( $type_name, App::Ack::Filter->create_filter('ext', @extensions) );
    }
    else {
        App::Ack::die( "Invalid filter specification '$spec'" );
    }
}


sub _uninvert_filter {
    my ( $opt, @filters ) = @_;

    return unless defined $opt->{filters} && @filters;

    # Loop through all the registered filters.  If we hit one that
    # matches this extension and it's inverted, we need to delete it from
    # the options.
    for ( my $i = 0; $i < @{ $opt->{filters} }; $i++ ) {
        my $opt_filter = @{ $opt->{filters} }[$i];

        # XXX Do a real list comparison? This just checks string equivalence.
        if ( $opt_filter->is_inverted() && "$opt_filter->{filter}" eq "@filters" ) {
            splice @{ $opt->{filters} }, $i, 1;
            $i--;
        }
    }

    return;
}


sub _process_filetypes {
    my ( $opt, $arg_sources ) = @_;

    my %additional_specs;

    my $add_spec = sub {
        my ( undef, $spec ) = @_;

        my ( $name, $filter ) = _process_filter_spec($spec);

        push @{ $App::Ack::mappings{$name} }, $filter;

        $additional_specs{$name . '!'} = sub {
            my ( undef, $value ) = @_;

            my @filters = @{ $App::Ack::mappings{$name} };
            if ( not $value ) {
                @filters = map { $_->invert() } @filters;
            }
            else {
                _uninvert_filter( $opt, @filters );
            }

            push @{ $opt->{'filters'} }, @filters;
        };
    };

    my $set_spec = sub {
        my ( undef, $spec ) = @_;

        my ( $name, $filter ) = _process_filter_spec($spec);

        $App::Ack::mappings{$name} = [ $filter ];

        $additional_specs{$name . '!'} = sub {
            my ( undef, $value ) = @_;

            my @filters = @{ $App::Ack::mappings{$name} };
            if ( not $value ) {
                @filters = map { $_->invert() } @filters;
            }

            push @{ $opt->{'filters'} }, @filters;
        };
    };

    my $delete_spec = sub {
        my ( undef, $name ) = @_;

        delete $App::Ack::mappings{$name};
        delete $additional_specs{$name . '!'};
    };

    my %type_arg_specs = (
        'type-add=s' => $add_spec,
        'type-set=s' => $set_spec,
        'type-del=s' => $delete_spec,
    );

    my $p = opt_parser( 'no_auto_abbrev', 'pass_through' );
    foreach my $source (@{$arg_sources}) {
        my $args = $source->{contents};

        if ( ref($args) ) {
            # $args are modified in place, so no need to munge $arg_sources
            $p->getoptionsfromarray( $args, %type_arg_specs );
        }
        else {
            ( undef, $source->{contents} ) =
                $p->getoptionsfromstring( $args, %type_arg_specs );
        }
    }

    $additional_specs{'k|known-types'} = sub {
        my @filters = map { @{$_} } values(%App::Ack::mappings);

        push @{ $opt->{'filters'} }, @filters;
    };

    return \%additional_specs;
}


sub get_arg_spec {
    my ( $opt, $extra_specs ) = @_;


    sub _type_handler {
        my ( $getopt, $value ) = @_;

        my $cb_value = 1;
        if ( $value =~ s/^no// ) {
            $cb_value = 0;
        }

        my $callback;
        {
            no warnings;
            $callback = $extra_specs->{ $value . '!' };
        }

        if ( $callback ) {
            $callback->( $getopt, $cb_value );
        }
        else {
            App::Ack::die( "Unknown type '$value'" );
        }

        return;
    }

    return {
        1                   => sub { $opt->{1} = $opt->{m} = 1 },
        'A|after-context:-1'  => sub { shift; $opt->{A} = _context_value(shift) },
        'B|before-context:-1' => sub { shift; $opt->{B} = _context_value(shift) },
        'C|context:-1'        => sub { shift; $opt->{B} = $opt->{A} = _context_value(shift) },
        'break!'            => \$opt->{break},
        'c|count'           => \$opt->{c},
        'color|colour!'     => \$opt->{color},
        'color-match=s'     => \$ENV{ACK_COLOR_MATCH},
        'color-filename=s'  => \$ENV{ACK_COLOR_FILENAME},
        'color-colno=s'     => \$ENV{ACK_COLOR_COLNO},
        'color-lineno=s'    => \$ENV{ACK_COLOR_LINENO},
        'column!'           => \$opt->{column},
        'create-ackrc'      => sub { say for ( '--ignore-ack-defaults', App::Ack::ConfigDefault::options() ); exit; },
        'debug'             => \$opt->{debug},
        'env!'              => sub {
            my ( undef, $value ) = @_;

            if ( !$value ) {
                $opt->{noenv_seen} = 1;
            }
        },
        f                   => \$opt->{f},
        'files-from=s'      => \$opt->{files_from},
        'filter!'           => \$App::Ack::is_filter_mode,
        flush               => sub { $| = 1 },
        'follow!'           => \$opt->{follow},
        g                   => \$opt->{g},
        'group!'            => sub { shift; $opt->{heading} = $opt->{break} = shift },
        'heading!'          => \$opt->{heading},
        'h|no-filename'     => \$opt->{h},
        'H|with-filename'   => \$opt->{H},
        'i|ignore-case'     => sub { $opt->{i} = 1; $opt->{S} = 0; },
        'I|no-ignore-case'  => sub { $opt->{i} = 0; $opt->{S} = 0; },
        'ignore-directory|ignore-dir=s' => _generate_ignore_dir('--ignore-dir', $opt),
        'ignore-file=s'     => sub {
            my ( undef, $file ) = @_;

            my ( $filter_type, $args ) = split /:/, $file, 2;

            my $filter = App::Ack::Filter->create_filter($filter_type, split(/,/, $args//''));

            if ( !$opt->{ifiles} ) {
                $opt->{ifiles} = App::Ack::Filter::Collection->new();
            }
            $opt->{ifiles}->add($filter);
        },
        'l|files-with-matches'
                            => \$opt->{l},
        'L|files-without-matches'
                            => \$opt->{L},
        'm|max-count=i'     => \$opt->{m},
        'match=s'           => \$opt->{regex},
        'n|no-recurse'      => \$opt->{n},
        o                   => sub { $opt->{output} = '$&' },
        'output=s'          => \$opt->{output},
        'pager:s'           => sub {
            my ( undef, $value ) = @_;

            $opt->{pager} = $value || $ENV{PAGER};
        },
        'noignore-directory|noignore-dir=s' => _generate_ignore_dir('--noignore-dir', $opt),
        'nopager'           => sub { $opt->{pager} = undef },
        'passthru'          => \$opt->{passthru},
        'print0'            => \$opt->{print0},
        'p|proximate:1'     => \$opt->{p},
        'P'                 => sub { $opt->{p} = 0 },
        'Q|literal'         => \$opt->{Q},
        'r|R|recurse'       => sub { $opt->{n} = 0 },
        'range-start=s'     => \$opt->{range_start},
        'range-end=s'       => \$opt->{range_end},
        'range-invert!'     => \$opt->{range_invert},
        's'                 => \$opt->{s},
        'show-types'        => \$opt->{show_types},
        'S|smart-case!'     => sub { my (undef,$value) = @_; $opt->{S} = $value; $opt->{i} = 0 if $value; },
        'sort-files'        => \$opt->{sort_files},
        't|type=s'          => \&_type_handler,
        'T=s'               => sub { my ($getopt,$value) = @_; $value="no$value"; _type_handler($getopt,$value); },
        'underline!'        => \$opt->{underline},
        'v|invert-match'    => \$opt->{v},
        'w|word-regexp'     => \$opt->{w},
        'x'                 => sub { $opt->{files_from} = '-' },

        'help'              => sub { App::Ack::show_help(); exit; },
        'help-types'        => sub { App::Ack::show_help_types(); exit; },
        'help-colors'       => sub { App::Ack::show_help_colors(); exit; },
        'help-rgb-colors'   => sub { App::Ack::show_help_rgb(); exit; },
        $extra_specs ? %{$extra_specs} : (),
    }; # arg_specs
}


sub _context_value {
    my $val = shift;

    # Contexts default to 2.
    return (!defined($val) || ($val < 0)) ? 2 : $val;
}


sub _process_other {
    my ( $opt, $extra_specs, $arg_sources ) = @_;

    my $argv_source;
    my $is_help_types_active;

    foreach my $source (@{$arg_sources}) {
        if ( $source->{name} eq 'ARGV' ) {
            $argv_source = $source->{contents};
            last;
        }
    }

    if ( $argv_source ) { # This *should* always be true, but you never know...
        my $p = opt_parser( 'pass_through' );
        $p->getoptionsfromarray( [ @{$argv_source} ],
            'help-types' => \$is_help_types_active,
        );
    }

    my $arg_specs = get_arg_spec( $opt, $extra_specs );

    my $p = opt_parser();
    foreach my $source (@{$arg_sources}) {
        my ( $source_name, $args ) = @{$source}{qw/name contents/};

        my $args_for_source = { %{$arg_specs} };

        if ( $source->{is_ackrc} ) {
            my $illegal = sub {
                my $name = shift;
                App::Ack::die( "Option --$name is forbidden in .ackrc files." );
            };

            $args_for_source = {
                %{$args_for_source},
                'output=s' => $illegal,
                'match=s'  => $illegal,
            };
        }
        if ( $source->{project} ) {
            my $illegal = sub {
                my $name = shift;
                App::Ack::die( "Option --$name is forbidden in project .ackrc files." );
            };

            $args_for_source = {
                %{$args_for_source},
                'pager:s' => $illegal,
            };
        }

        my $ret;
        if ( ref($args) ) {
            $ret = $p->getoptionsfromarray( $args, %{$args_for_source} );
        }
        else {
            ( $ret, $source->{contents} ) =
                $p->getoptionsfromstring( $args, %{$args_for_source} );
        }
        if ( !$ret ) {
            if ( !$is_help_types_active ) {
                my $where = $source_name eq 'ARGV' ? 'on command line' : "in $source_name";
                App::Ack::die( "Invalid option $where" );
            }
        }
        if ( $opt->{noenv_seen} ) {
            App::Ack::die( "--noenv found in $source_name" );
        }
    }

    # XXX We need to check on a -- in the middle of a non-ARGV source

    return;
}


sub _explode_sources {
    my ( $sources ) = @_;

    my @new_sources;

    my %opt;
    my $arg_spec = get_arg_spec( \%opt, {} );

    my $dummy_sub = sub {};
    my $add_type = sub {
        my ( undef, $arg ) = @_;

        if ( $arg =~ /(\w+)=/) {
            $arg_spec->{$1} = $dummy_sub;
        }
        else {
            ( $arg ) = split /:/, $arg;
            $arg_spec->{$arg} = $dummy_sub;
        }
    };

    my $del_type = sub {
        my ( undef, $arg ) = @_;

        delete $arg_spec->{$arg};
    };

    my $p = opt_parser( 'pass_through' );
    foreach my $source (@{$sources}) {
        my ( $name, $options ) = @{$source}{qw/name contents/};
        if ( ref($options) ne 'ARRAY' ) {
            $source->{contents} = $options =
                [ Text::ParseWords::shellwords($options) ];
        }

        for my $j ( 0 .. @{$options}-1 ) {
            next unless $options->[$j] =~ /^-/;
            my @chunk = ( $options->[$j] );
            push @chunk, $options->[$j] while ++$j < @{$options} && $options->[$j] !~ /^-/;
            $j--;

            my @copy = @chunk;
            $p->getoptionsfromarray( [@chunk],
                'type-add=s' => $add_type,
                'type-set=s' => $add_type,
                'type-del=s' => $del_type,
                %{$arg_spec}
            );

            push @new_sources, {
                name     => $name,
                contents => \@copy,
            };
        }
    }

    return \@new_sources;
}


sub _compare_opts {
    my ( $a, $b ) = @_;

    my $first_a = $a->[0];
    my $first_b = $b->[0];

    $first_a =~ s/^--?//;
    $first_b =~ s/^--?//;

    return $first_a cmp $first_b;
}


sub _dump_options {
    my ( $sources ) = @_;

    $sources = _explode_sources($sources);

    my %opts_by_source;
    my @source_names;

    foreach my $source (@{$sources}) {
        my $name = $source->{name};
        if ( not $opts_by_source{$name} ) {
            $opts_by_source{$name} = [];
            push @source_names, $name;
        }
        push @{$opts_by_source{$name}}, $source->{contents};
    }

    foreach my $name (@source_names) {
        my $contents = $opts_by_source{$name};

        say $name;
        say '=' x length($name);
        say '  ', join(' ', @{$_}) for sort { _compare_opts($a, $b) } @{$contents};
    }

    return;
}


sub _remove_default_options_if_needed {
    my ( $sources ) = @_;

    my $default_index;

    foreach my $index ( 0 .. $#{$sources} ) {
        if ( $sources->[$index]{'name'} eq 'Defaults' ) {
            $default_index = $index;
            last;
        }
    }

    return $sources unless defined $default_index;

    my $should_remove = 0;

    my $p = opt_parser( 'no_auto_abbrev', 'pass_through' );

    foreach my $index ( $default_index + 1 .. $#{$sources} ) {
        my $args = $sources->[$index]->{contents};

        if (ref($args)) {
            $p->getoptionsfromarray( $args,
                'ignore-ack-defaults' => \$should_remove,
            );
        }
        else {
            ( undef, $sources->[$index]{contents} ) = $p->getoptionsfromstring( $args,
                'ignore-ack-defaults' => \$should_remove,
            );
        }
    }

    return $sources unless $should_remove;

    my @copy = @{$sources};
    splice @copy, $default_index, 1;
    return \@copy;
}


sub process_args {
    my $arg_sources = \@_;

    my %opt = (
        pager => $ENV{ACK_PAGER_COLOR} || $ENV{ACK_PAGER},
    );

    $arg_sources = _remove_default_options_if_needed($arg_sources);

    # Check for --dump early.
    foreach my $source (@{$arg_sources}) {
        if ( $source->{name} eq 'ARGV' ) {
            my $dump;
            my $p = opt_parser( 'pass_through' );
            $p->getoptionsfromarray( $source->{contents},
                'dump' => \$dump,
            );
            if ( $dump ) {
                _dump_options($arg_sources);
                exit(0);
            }
        }
    }

    my $type_specs = _process_filetypes(\%opt, $arg_sources);

    _check_for_mutex_options( $type_specs );

    _process_other(\%opt, $type_specs, $arg_sources);
    while ( @{$arg_sources} ) {
        my $source = shift @{$arg_sources};
        my $args = $source->{contents};

        # All of our sources should be transformed into an array ref
        if ( ref($args) ) {
            my $source_name = $source->{name};
            if ( $source_name eq 'ARGV' ) {
                @ARGV = @{$args};
            }
            elsif (@{$args}) {
                App::Ack::die( "Source '$source_name' has extra arguments!" );
            }
        }
        else {
            App::Ack::die( 'The impossible has occurred!' );
        }
    }
    my $filters = ($opt{filters} ||= []);

    # Throw the default filter in if no others are selected.
    if ( not grep { !$_->is_inverted() } @{$filters} ) {
        push @{$filters}, App::Ack::Filter::Default->new();
    }
    return \%opt;
}


sub retrieve_arg_sources {
    my @arg_sources;

    my $noenv;
    my $ackrc;

    my $p = opt_parser( 'no_auto_abbrev', 'pass_through' );
    $p->getoptions(
        'noenv'   => \$noenv,
        'ackrc=s' => \$ackrc,
    );

    my @files;

    if ( !$noenv ) {
        my $finder = App::Ack::ConfigFinder->new;
        @files  = $finder->find_config_files;
    }
    if ( $ackrc ) {
        # We explicitly use open so we get a nice error message.
        # XXX This is a potential race condition!.
        if ( open my $fh, '<', $ackrc ) {
            close $fh;
        }
        else {
            App::Ack::die( "Unable to load ackrc '$ackrc': $!" );
        }
        push( @files, { path => $ackrc } );
    }

    push @arg_sources, {
        name     => 'Defaults',
        contents => [ App::Ack::ConfigDefault::options_clean() ],
    };

    foreach my $file ( @files) {
        my @lines = read_rcfile($file->{path});
        if ( @lines ) {
            push @arg_sources, {
                name     => $file->{path},
                contents => \@lines,
                project  => $file->{project},
                is_ackrc => 1,
            };
        }
    }

    push @arg_sources, {
        name     => 'ARGV',
        contents => [ @ARGV ],
    };

    return @arg_sources;
}


sub read_rcfile {
    my $file = shift;

    return unless defined $file && -e $file;

    my @lines;

    open( my $fh, '<', $file ) or App::Ack::die( "Unable to read $file: $!" );
    while ( defined( my $line = <$fh> ) ) {
        chomp $line;
        $line =~ s/^\s+//;
        $line =~ s/\s+$//;

        next if $line eq '';
        next if $line =~ /^\s*#/;

        push( @lines, $line );
    }
    close $fh or App::Ack::die( "Unable to close $file: $!" );

    return @lines;
}


# Verifies no mutex options were passed.  Dies if they were.
sub _check_for_mutex_options {
    my $type_specs = shift;

    my $mutex = mutex_options();

    my ($raw,$used) = _options_used( $type_specs );

    my @used = sort { lc $a cmp lc $b } keys %{$used};

    for my $i ( @used ) {
        for my $j ( @used ) {
            next if $i eq $j;
            if ( $mutex->{$i}{$j} ) {
                my $x = $raw->[ $used->{$i} ];
                my $y = $raw->[ $used->{$j} ];
                App::Ack::die( "Options '$x' and '$y' can't be used together." );
            }
        }
    }

    return;
}


# Processes the command line option and returns a hash of the options that were
# used on the command line, using their full name.  "--prox" shows up in the hash as "--proximate".
sub _options_used {
    my $type_specs = shift;

    my %dummy_opt;
    my $real_spec = get_arg_spec( \%dummy_opt, $type_specs );

    # The real argument parsing doesn't check for --type-add, --type-del or --type-set because
    # they get removed by the argument processing.  We have to account for them here.
    my $sub_dummy = sub {};
    $real_spec = {
        %{$real_spec},
        'type-add=s'          => $sub_dummy,
        'type-del=s'          => $sub_dummy,
        'type-set=s'          => $sub_dummy,
        'ignore-ack-defaults' => $sub_dummy,
    };

    my %parsed;
    my @raw;
    my %spec_capture_parsed;
    my %spec_capture_raw;


    # Capture the %parsed hash.
    CAPTURE_PARSED: {
        my $parsed_pos = 0;
        my $sub_count = sub {
            my $arg = shift;
            $arg = "$arg";
            $parsed{$arg} = $parsed_pos++;
        };
        %spec_capture_parsed = (
            '<>' => sub { $parsed_pos++ },  # Bump forward one pos for non-options.
            map { $_ => $sub_count } keys %{$real_spec}
        );
    }

    # Capture the @raw array.
    CAPTURE_RAW: {
        my $raw_pos = 0;
        %spec_capture_raw = (
            '<>' => sub { $raw_pos++ }, # Bump forward one pos for non-options.
        );

        my $sub_count = sub {
            my $arg = shift;

            $arg = "$arg";
            $raw[$raw_pos] = length($arg) == 1 ? "-$arg" : "--$arg";
            $raw_pos++;
        };

        for my $opt_spec ( keys %{$real_spec} ) {
            my $negatable;
            my $type;
            my $default;

            $negatable = ($opt_spec =~ s/!$//);

            if ( $opt_spec =~ s/(=[si])$// ) {
                $type = $1;
            }
            if ( $opt_spec =~ s/(:.+)$// ) {
                $default = $1;
            }

            my @aliases = split( /\|/, $opt_spec );
            for my $alias ( @aliases ) {
                $alias .= $type    if defined $type;
                $alias .= $default if defined $default;
                $alias .= '!'      if $negatable;

                $spec_capture_raw{$alias} = $sub_count;
            }
        }
    }

    # Parse @ARGV twice, once with each capture spec.
    my $p = opt_parser( 'pass_through' );   # Ignore invalid options.
    $p->getoptionsfromarray( [@ARGV], %spec_capture_raw );
    $p->getoptionsfromarray( [@ARGV], %spec_capture_parsed );

    return (\@raw,\%parsed);
}


sub mutex_options {
    # This list is machine-generated by dev/crank-mutex.  Do not modify it by hand.

    return {
        1 => {
            m => 1,
            passthru => 1,
        },
        A => {
            L => 1,
            c => 1,
            f => 1,
            g => 1,
            l => 1,
            o => 1,
            output => 1,
            p => 1,
            passthru => 1,
        },
        B => {
            L => 1,
            c => 1,
            f => 1,
            g => 1,
            l => 1,
            o => 1,
            output => 1,
            p => 1,
            passthru => 1,
        },
        C => {
            L => 1,
            c => 1,
            f => 1,
            g => 1,
            l => 1,
            o => 1,
            output => 1,
            p => 1,
            passthru => 1,
        },
        H => {
            L => 1,
            f => 1,
            g => 1,
            l => 1,
        },
        L => {
            A => 1,
            B => 1,
            C => 1,
            H => 1,
            L => 1,
            break => 1,
            c => 1,
            column => 1,
            f => 1,
            g => 1,
            group => 1,
            h => 1,
            heading => 1,
            l => 1,
            'no-filename' => 1,
            o => 1,
            output => 1,
            p => 1,
            passthru => 1,
            'show-types' => 1,
            v => 1,
            'with-filename' => 1,
        },
        break => {
            L => 1,
            c => 1,
            f => 1,
            g => 1,
            l => 1,
        },
        c => {
            A => 1,
            B => 1,
            C => 1,
            L => 1,
            break => 1,
            column => 1,
            f => 1,
            g => 1,
            group => 1,
            heading => 1,
            m => 1,
            o => 1,
            output => 1,
            p => 1,
            passthru => 1,
        },
        column => {
            L => 1,
            c => 1,
            f => 1,
            g => 1,
            l => 1,
            o => 1,
            output => 1,
            passthru => 1,
            v => 1,
        },
        f => {
            A => 1,
            B => 1,
            C => 1,
            H => 1,
            L => 1,
            break => 1,
            c => 1,
            column => 1,
            f => 1,
            'files-from' => 1,
            g => 1,
            group => 1,
            h => 1,
            heading => 1,
            l => 1,
            m => 1,
            match => 1,
            o => 1,
            output => 1,
            p => 1,
            passthru => 1,
            u => 1,
            v => 1,
            x => 1,
        },
        'files-from' => {
            f => 1,
            g => 1,
            x => 1,
        },
        g => {
            A => 1,
            B => 1,
            C => 1,
            H => 1,
            L => 1,
            break => 1,
            c => 1,
            column => 1,
            f => 1,
            'files-from' => 1,
            g => 1,
            group => 1,
            h => 1,
            heading => 1,
            l => 1,
            m => 1,
            match => 1,
            o => 1,
            output => 1,
            p => 1,
            passthru => 1,
            u => 1,
            x => 1,
        },
        group => {
            L => 1,
            c => 1,
            f => 1,
            g => 1,
            l => 1,
        },
        h => {
            L => 1,
            f => 1,
            g => 1,
            l => 1,
        },
        heading => {
            L => 1,
            c => 1,
            f => 1,
            g => 1,
            l => 1,
        },
        l => {
            A => 1,
            B => 1,
            C => 1,
            H => 1,
            L => 1,
            break => 1,
            column => 1,
            f => 1,
            g => 1,
            group => 1,
            h => 1,
            heading => 1,
            l => 1,
            'no-filename' => 1,
            o => 1,
            output => 1,
            p => 1,
            passthru => 1,
            'show-types' => 1,
            'with-filename' => 1,
        },
        m => {
            1 => 1,
            c => 1,
            f => 1,
            g => 1,
            passthru => 1,
        },
        match => {
            f => 1,
            g => 1,
        },
        'no-filename' => {
            L => 1,
            l => 1,
        },
        o => {
            A => 1,
            B => 1,
            C => 1,
            L => 1,
            c => 1,
            column => 1,
            f => 1,
            g => 1,
            l => 1,
            o => 1,
            output => 1,
            p => 1,
            passthru => 1,
            'show-types' => 1,
            v => 1,
        },
        output => {
            A => 1,
            B => 1,
            C => 1,
            L => 1,
            c => 1,
            column => 1,
            f => 1,
            g => 1,
            l => 1,
            o => 1,
            output => 1,
            p => 1,
            passthru => 1,
            'show-types' => 1,
            u => 1,
            v => 1,
        },
        p => {
            A => 1,
            B => 1,
            C => 1,
            L => 1,
            c => 1,
            f => 1,
            g => 1,
            l => 1,
            o => 1,
            output => 1,
            p => 1,
            passthru => 1,
        },
        passthru => {
            1 => 1,
            A => 1,
            B => 1,
            C => 1,
            L => 1,
            c => 1,
            column => 1,
            f => 1,
            g => 1,
            l => 1,
            m => 1,
            o => 1,
            output => 1,
            p => 1,
            v => 1,
        },
        'show-types' => {
            L => 1,
            l => 1,
            o => 1,
            output => 1,
        },
        u => {
            f => 1,
            g => 1,
            output => 1,
        },
        v => {
            L => 1,
            column => 1,
            f => 1,
            o => 1,
            output => 1,
            passthru => 1,
        },
        'with-filename' => {
            L => 1,
            l => 1,
        },
        x => {
            f => 1,
            'files-from' => 1,
            g => 1,
        },
    };

}   # End of mutex_options()


1; # End of App::Ack::ConfigLoader
package App::Ack::File;

use warnings;
use strict;

use File::Spec ();


sub new {
    my $class    = shift;
    my $filename = shift;

    my $self = bless {
        filename => $filename,
        fh       => undef,
    }, $class;

    if ( $self->{filename} eq '-' ) {
        $self->{fh}     = *STDIN;
    }

    return $self;
}



sub name {
    return $_[0]->{filename};
}



sub basename {
    my ( $self ) = @_;

    return $self->{basename} //= (File::Spec->splitpath($self->name))[2];
}



sub open {
    my ( $self ) = @_;

    if ( !$self->{fh} ) {
        if ( open $self->{fh}, '<', $self->{filename} ) {
            # Do nothing.
        }
        else {
            $self->{fh} = undef;
        }
    }

    return $self->{fh};
}


sub may_be_present {
    my $self  = shift;
    my $regex = shift;

    # Tells if the file needs a line-by-line scan.  This is a big
    # optimization because if you can tell from the outset that the pattern
    # is not found in the file at all, then there's no need to do the
    # line-by-line iteration.

    # Slurp up an entire file up to 10M, see if there are any matches
    # in it, and if so, let us know so we can iterate over it directly.

    # The $regex may be undef if it had a "$" in it, and is therefore unsuitable for this heuristic.

    my $may_be_present = 1;
    if ( $regex && $self->open() && -f $self->{fh} ) {
        my $buffer;
        my $size = 10_000_000;
        my $rc = sysread( $self->{fh}, $buffer, $size );
        if ( !defined($rc) ) {
            if ( $App::Ack::report_bad_filenames ) {
                App::Ack::warn( $self->name . ": $!" );
            }
            $may_be_present = 0;
        }
        else {
            # If we read all 10M, then we need to scan the rest.
            # If there are any carriage returns, our results are flaky, so scan the rest.
            if ( ($rc == $size) || (index($buffer,"\r") >= 0) ) {
                $may_be_present = 1;
            }
            else {
                if ( $buffer !~ /$regex/o ) {
                    $may_be_present = 0;
                }
            }
        }
    }

    return $may_be_present;
}



sub reset {
    my $self = shift;

    if ( defined($self->{fh}) ) {
        return unless -f $self->{fh};

        if ( !seek( $self->{fh}, 0, 0 ) && $App::Ack::report_bad_filenames ) {
            App::Ack::warn( "$self->{filename}: $!" );
        }
    }

    return;
}



sub close {
    my $self = shift;

    if ( $self->{fh} ) {
        if ( !close($self->{fh}) && $App::Ack::report_bad_filenames ) {
            App::Ack::warn( $self->name() . ": $!" );
        }
        $self->{fh} = undef;
    }

    return;
}



sub clone {
    my ( $self ) = @_;

    return __PACKAGE__->new($self->name);
}



sub firstliney {
    my ( $self ) = @_;

    if ( !exists $self->{firstliney} ) {
        my $fh = $self->open();
        if ( !$fh ) {
            if ( $App::Ack::report_bad_filenames ) {
                App::Ack::warn( $self->name . ': ' . $! );
            }
            $self->{firstliney} = '';
        }
        else {
            my $buffer;
            my $rc = sysread( $fh, $buffer, 250 );
            if ( $rc ) {
                $buffer =~ s/[\r\n].*//s;
            }
            else {
                if ( !defined($rc) ) {
                    App::Ack::warn( $self->name . ': ' . $! );
                }
                $buffer = '';
            }
            $self->{firstliney} = $buffer;
            $self->reset;
        }
    }

    return $self->{firstliney};
}

1;
package App::Ack::Files;



use warnings;
use strict;
use 5.010;


sub from_argv {
    my $class = shift;
    my $opt   = shift;
    my $start = shift;

    my $self = bless {}, $class;

    my $descend_filter = $opt->{descend_filter};

    if ( $opt->{n} ) {
        $descend_filter = sub {
            return 0;
        };
    }

    $self->{iter} =
        File::Next::files( {
            file_filter     => $opt->{file_filter},
            descend_filter  => $descend_filter,
            error_handler   => _generate_error_handler(),
            warning_handler => sub {},
            sort_files      => $opt->{sort_files},
            follow_symlinks => $opt->{follow},
        }, @{$start} );

    return $self;
}


sub from_file {
    my $class = shift;
    my $opt   = shift;
    my $file  = shift;

    my $error_handler = _generate_error_handler();
    my $iter =
        File::Next::from_file( {
            error_handler   => $error_handler,
            warning_handler => $error_handler,
            sort_files      => $opt->{sort_files},
        }, $file ) or return undef;

    return bless {
        iter => $iter,
    }, $class;
}




sub from_stdin {
    my $class = shift;

    my $self  = bless {}, $class;

    $self->{iter} = sub {
        state $has_been_called = 0;

        if ( !$has_been_called ) {
            $has_been_called = 1;
            return '-';
        }
        return;
    };

    return $self;
}


sub next {
    my $self = shift;

    my $file = $self->{iter}->();

    return unless defined($file);

    return App::Ack::File->new( $file );
}


sub _generate_error_handler {
    if ( $App::Ack::report_bad_filenames ) {
        return sub {
            my $msg = shift;
            App::Ack::warn( $msg );
        };
    }
    else {
        return sub {};
    }
}

1;
package App::Ack::Filter;

use strict;
use warnings;


my %filter_types;


sub create_filter {
    my ( undef, $type, @args ) = @_;

    if ( my $package = $filter_types{$type} ) {
        return $package->new(@args);
    }
    my $allowed_types = join( ', ', sort keys %filter_types );
    App::Ack::die( "Unknown filter type '$type'.  Type must be one of: $allowed_types." );
}


sub register_filter {
    my ( undef, $type, $package ) = @_;

    $filter_types{$type} = $package;

    return;
}


sub invert {
    my ( $self ) = @_;

    return App::Ack::Filter::Inverse->new( $self );
}


sub is_inverted {
    return 0;
}


sub to_string {
    return '(unimplemented to_string)';
}


sub inspect {
    my ( $self ) = @_;

    return ref($self);
}

1;
package App::Ack::Filter::Collection;


use strict;
use warnings;
BEGIN {
    our @ISA = 'App::Ack::Filter';
}

sub new {
    my ( $class ) = @_;

    return bless {
        groups => {},
        ungrouped => [],
    }, $class;
}

sub filter {
    my ( $self, $file ) = @_;

    for my $group (values %{$self->{groups}}) {
        return 1 if $group->filter($file);
    }

    for my $filter (@{$self->{ungrouped}}) {
        return 1 if $filter->filter($file);
    }

    return 0;
}

sub add {
    my ( $self, $filter ) = @_;

    if (exists $filter->{'groupname'}) {
        my $group = ($self->{groups}->{$filter->{groupname}} ||= $filter->create_group());
        $group->add($filter);
    }
    else {
        push @{$self->{'ungrouped'}}, $filter;
    }

    return;
}

sub inspect {
    my ( $self ) = @_;

    return ref($self) . " - $self";
}

sub to_string {
    my ( $self ) = @_;

    return join(', ', map { "($_)" } @{$self->{ungrouped}});
}

1;
package App::Ack::Filter::Default;


use strict;
use warnings;
BEGIN {
    our @ISA = 'App::Ack::Filter';
}

sub new {
    my ( $class ) = @_;

    return bless {}, $class;
}

sub filter {
    my ( undef, $file ) = @_;

    return -T $file->name;
}

1;
package App::Ack::Filter::Extension;


use strict;
use warnings;
BEGIN {
    our @ISA = 'App::Ack::Filter';
}


sub new {
    my ( $class, @extensions ) = @_;

    my $exts = join('|', map { "\Q$_\E"} @extensions);
    my $re   = qr/[.](?:$exts)$/i;

    return bless {
        extensions => \@extensions,
        regex      => $re,
        groupname  => 'ExtensionGroup',
    }, $class;
}

sub create_group {
    return App::Ack::Filter::ExtensionGroup->new();
}

sub filter {
    my ( $self, $file ) = @_;

    return $file->name =~ /$self->{regex}/;
}

sub inspect {
    my ( $self ) = @_;

    return ref($self) . ' - ' . $self->{regex};
}

sub to_string {
    my ( $self ) = @_;

    return join( ' ', map { ".$_" } @{$self->{extensions}} );
}

BEGIN {
    App::Ack::Filter->register_filter(ext => __PACKAGE__);
}

1;
package App::Ack::Filter::ExtensionGroup;


use strict;
use warnings;
BEGIN {
    our @ISA = 'App::Ack::Filter';
}

sub new {
    my ( $class ) = @_;

    return bless {
        data => {},
    }, $class;
}

sub add {
    my ( $self, $filter ) = @_;

    foreach my $ext (@{$filter->{extensions}}) {
        $self->{data}->{lc $ext} = 1;
    }

    return;
}

sub filter {
    my ( $self, $file ) = @_;

    if ($file->name =~ /[.]([^.]*)$/) {
        return exists $self->{'data'}->{lc $1};
    }

    return 0;
}

sub inspect {
    my ( $self ) = @_;

    return ref($self) . " - $self";
}

sub to_string {
    my ( $self ) = @_;

    return join(' ', map { ".$_" } sort keys %{$self->{data}});
}

1;
package App::Ack::Filter::FirstLineMatch;



use strict;
use warnings;
BEGIN {
    our @ISA = 'App::Ack::Filter';
}

sub new {
    my ( $class, $re ) = @_;

    $re =~ s{^/|/$}{}g; # XXX validate?
    $re = qr{$re}i;

    return bless {
        regex => $re,
    }, $class;
}

# This test reads the first 250 characters of a file, then just uses the
# first line found in that. This prevents reading something  like an entire
# .min.js file (which might be only one "line" long) into memory.

sub filter {
    my ( $self, $file ) = @_;

    return $file->firstliney =~ /$self->{regex}/;
}

sub inspect {
    my ( $self ) = @_;


    return ref($self) . ' - ' . $self->{regex};
}

sub to_string {
    my ( $self ) = @_;

    (my $re = $self->{regex}) =~ s{\([^:]*:(.*)\)$}{$1};

    return "First line matches /$re/";
}

BEGIN {
    App::Ack::Filter->register_filter(firstlinematch => __PACKAGE__);
}

1;
package App::Ack::Filter::Inverse;



use strict;
use warnings;
BEGIN {
    our @ISA = 'App::Ack::Filter';
}

sub new {
    my ( $class, $filter ) = @_;

    return bless {
        filter => $filter,
    }, $class;
}

sub filter {
    my ( $self, $file ) = @_;

    return !$self->{filter}->filter( $file );
}

sub invert {
    my $self = shift;

    return $self->{'filter'};
}

sub is_inverted {
    return 1;
}

sub inspect {
    my ( $self ) = @_;

    my $filter = $self->{'filter'};

    return "!$filter";
}

1;
package App::Ack::Filter::Is;


use strict;
use warnings;
BEGIN {
    our @ISA = 'App::Ack::Filter';
}

use File::Spec 3.00 ();

sub new {
    my ( $class, $filename ) = @_;

    return bless {
        filename => $filename,
        groupname => 'IsGroup',
    }, $class;
}

sub create_group {
    return App::Ack::Filter::IsGroup->new();
}

sub filter {
    my ( $self, $file ) = @_;

    return (File::Spec->splitpath($file->name))[2] eq $self->{filename};
}

sub inspect {
    my ( $self ) = @_;

    return ref($self) . ' - ' . $self->{filename};
}

sub to_string {
    my ( $self ) = @_;

    return $self->{filename};
}

BEGIN {
    App::Ack::Filter->register_filter(is => __PACKAGE__);
}

1;
package App::Ack::Filter::IsGroup;


use strict;
use warnings;
BEGIN {
    our @ISA = 'App::Ack::Filter';
}

sub new {
    my ( $class ) = @_;

    return bless {
        data => {},
    }, $class;
}

sub add {
    my ( $self, $filter ) = @_;

    $self->{data}->{ $filter->{filename} } = 1;

    return;
}

sub filter {
    my ( $self, $file ) = @_;

    return exists $self->{data}->{ $file->basename };
}

sub inspect {
    my ( $self ) = @_;

    return ref($self) . " - $self";
}

sub to_string {
    my ( $self ) = @_;

    return join(' ', keys %{$self->{data}});
}

1;
package App::Ack::Filter::IsPath;


use strict;
use warnings;
BEGIN {
    our @ISA = 'App::Ack::Filter';
}


sub new {
    my ( $class, $filename ) = @_;

    return bless {
        filename => $filename,
        groupname => 'IsPathGroup',
    }, $class;
}

sub create_group {
    return App::Ack::Filter::IsPathGroup->new();
}

sub filter {
    my ( $self, $file ) = @_;

    return $file->name eq $self->{filename};
}

sub inspect {
    my ( $self ) = @_;

    return ref($self) . ' - ' . $self->{filename};
}

sub to_string {
    my ( $self ) = @_;

    return $self->{filename};
}

1;
package App::Ack::Filter::IsPathGroup;


use strict;
use warnings;
BEGIN {
    our @ISA = 'App::Ack::Filter';
}

sub new {
    my ( $class ) = @_;

    return bless {
        data => {},
    }, $class;
}

sub add {
    my ( $self, $filter ) = @_;

    $self->{data}->{ $filter->{filename} } = 1;

    return;
}

sub filter {
    my ( $self, $file ) = @_;

    return exists $self->{data}->{$file->name};
}

sub inspect {
    my ( $self ) = @_;

    return ref($self) . " - $self";
}

sub to_string {
    my ( $self ) = @_;

    return join(' ', keys %{$self->{data}});
}

1;
package App::Ack::Filter::Match;

use strict;
use warnings;
BEGIN {
    our @ISA = 'App::Ack::Filter';
}



sub new {
    my ( $class, $re ) = @_;

    $re =~ s{^/|/$}{}g; # XXX validate?
    $re = qr/$re/i;

    return bless {
        regex => $re,
        groupname => 'MatchGroup',
    }, $class;
}

sub create_group {
    return App::Ack::Filter::MatchGroup->new;
}

sub filter {
    my ( $self, $file ) = @_;

    return $file->basename =~ /$self->{regex}/;
}

sub inspect {
    my ( $self ) = @_;

    return ref($self) . ' - ' . $self->{regex};
}

sub to_string {
    my ( $self ) = @_;

    return "Filename matches $self->{regex}";
}

BEGIN {
    App::Ack::Filter->register_filter(match => __PACKAGE__);
}

1;
package App::Ack::Filter::MatchGroup;


use strict;
use warnings;
BEGIN {
    our @ISA = 'App::Ack::Filter';
}

sub new {
    my ( $class ) = @_;

    return bless {
        matches => [],
        big_re  => undef,
    }, $class;
}

sub add {
    my ( $self, $filter ) = @_;

    push @{ $self->{matches} }, $filter->{regex};

    my $re = join('|', map { "(?:$_)" } @{ $self->{matches} });
    $self->{big_re} = qr/$re/;

    return;
}

sub filter {
    my ( $self, $file ) = @_;

    return $file->basename =~ /$self->{big_re}/;
}

# This class has no inspect() or to_string() method.
# It will just use the default one unless someone writes something useful.

1;
package File::Next;

use strict;
use warnings;


our $VERSION = '1.18';



use File::Spec ();

our $name; # name of the current file
our $dir;  # dir of the current file

our %files_defaults;
our %skip_dirs;

BEGIN {
    %files_defaults = (
        file_filter     => undef,
        descend_filter  => undef,
        error_handler   => sub { CORE::die $_[0] },
        warning_handler => sub { CORE::warn @_ },
        sort_files      => undef,
        follow_symlinks => 1,
        nul_separated   => 0,
    );
    %skip_dirs = map {($_,1)} (File::Spec->curdir, File::Spec->updir);
}


sub files {
    die _bad_invocation() if @_ && defined($_[0]) && ($_[0] eq __PACKAGE__);

    my ($parms,@queue) = _setup( \%files_defaults, @_ );

    my $filter = $parms->{file_filter};
    return sub {
        while ( my $entry = shift @queue ) {
            my ( $dirname, $file, $fullpath, $is_dir, $is_file, $is_fifo ) = @{$entry};
            if ( $is_file || $is_fifo ) {
                if ( $filter ) {
                    local $_ = $file;
                    local $File::Next::dir = $dirname;
                    local $File::Next::name = $fullpath;
                    next if not $filter->();
                }
                return wantarray ? ($dirname,$file,$fullpath) : $fullpath;
            }
            if ( $is_dir ) {
                unshift( @queue, _candidate_files( $parms, $fullpath ) );
            }
        } # while

        return;
    }; # iterator
}







sub from_file {
    die _bad_invocation() if @_ && defined($_[0]) && ($_[0] eq __PACKAGE__);

    my ($parms,@queue) = _setup( \%files_defaults, @_ );
    my $err  = $parms->{error_handler};
    my $warn = $parms->{warning_handler};

    my $filename = $queue[0]->[1];

    if ( !defined($filename) ) {
        $err->( 'Must pass a filename to from_file()' );
        return undef;
    }

    my $fh;
    if ( $filename eq '-' ) {
        $fh = \*STDIN;
    }
    else {
        if ( !open( $fh, '<', $filename ) ) {
            $err->( "Unable to open $filename: $!", $! + 0 );
            return undef;
        }
    }

    my $filter = $parms->{file_filter};
    return sub {
        local $/ = $parms->{nul_separated} ? "\x00" : $/;
        while ( my $fullpath = <$fh> ) {
            chomp $fullpath;
            next unless $fullpath =~ /./;
            if ( not ( -f $fullpath || -p _ ) ) {
                $warn->( "$fullpath: No such file" );
                next;
            }

            my ($volume,$dirname,$file) = File::Spec->splitpath( $fullpath );
            if ( $filter ) {
                local $_ = $file;
                local $File::Next::dir  = $dirname;
                local $File::Next::name = $fullpath;
                next if not $filter->();
            }
            return wantarray ? ($dirname,$file,$fullpath) : $fullpath;
        } # while
        close $fh;

        return;
    }; # iterator
}

sub _bad_invocation {
    my $good = (caller(1))[3];
    my $bad  = $good;
    $bad =~ s/(.+)::/$1->/;
    return "$good must not be invoked as $bad";
}

sub sort_standard($$)   { return $_[0]->[1] cmp $_[1]->[1] }
sub sort_reverse($$)    { return $_[1]->[1] cmp $_[0]->[1] }

sub reslash {
    my $path = shift;

    my @parts = split( /\//, $path );

    return $path if @parts < 2;

    return File::Spec->catfile( @parts );
}



sub _setup {
    my $defaults = shift;
    my $passed_parms = ref $_[0] eq 'HASH' ? {%{+shift}} : {}; # copy parm hash

    my %passed_parms = %{$passed_parms};

    my $parms = {};
    for my $key ( keys %{$defaults} ) {
        $parms->{$key} =
            exists $passed_parms{$key}
                ? delete $passed_parms{$key}
                : $defaults->{$key};
    }

    # Any leftover keys are bogus
    for my $badkey ( sort keys %passed_parms ) {
        my $sub = (caller(1))[3];
        $parms->{error_handler}->( "Invalid option passed to $sub(): $badkey" );
    }

    # If it's not a code ref, assume standard sort
    if ( $parms->{sort_files} && ( ref($parms->{sort_files}) ne 'CODE' ) ) {
        $parms->{sort_files} = \&sort_standard;
    }
    my @queue;

    for ( @_ ) {
        my $start = reslash( $_ );
        my $is_dir  = -d $start;
        my $is_file = -f _;
        my $is_fifo = (-p _) || ($start =~ m{^/dev/fd});
        push @queue,
            $is_dir
                ? [ $start, undef,  $start, $is_dir, $is_file, $is_fifo ]
                : [ undef,  $start, $start, $is_dir, $is_file, $is_fifo ];
    }

    return ($parms,@queue);
}


sub _candidate_files {
    my $parms   = shift;
    my $dirname = shift;

    my $dh;
    if ( !opendir $dh, $dirname ) {
        $parms->{error_handler}->( "$dirname: $!", $! + 0 );
        return;
    }

    my @newfiles;
    my $descend_filter = $parms->{descend_filter};
    my $follow_symlinks = $parms->{follow_symlinks};

    for my $file ( grep { !exists $skip_dirs{$_} } readdir $dh ) {
        my $fullpath = File::Spec->catdir( $dirname, $file );
        if ( !$follow_symlinks ) {
            next if -l $fullpath;
        }
        else {
            stat($fullpath);
        }
        my $is_dir  = -d _;
        my $is_file = -f _;
        my $is_fifo = (-p _) || ($fullpath =~ m{^/dev/fd});

        # Only do directory checking if we have a descend_filter
        if ( $descend_filter ) {
            if ( $is_dir ) {
                local $File::Next::dir = $fullpath;
                local $_ = $file;
                next if not $descend_filter->();
            }
        }
        push @newfiles, [ $dirname, $file, $fullpath, $is_dir, $is_file, $is_fifo ];
    }
    closedir $dh;

    my $sort_sub = $parms->{sort_files};
    if ( $sort_sub ) {
        @newfiles = sort $sort_sub @newfiles;
    }

    return @newfiles;
}



1; # End of File::Next
