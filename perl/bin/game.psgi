#!/usr/local/bin/perl5.10.0

use strict;
use warnings;

use Web::Simple 'GameIF';

{
    package GameIF;
    use Game;
    use File::Spec::Functions;
    use Data::Dump::Streamer 'Dumper';

    my @games = ();

    default_config ( file_dir => q{/usr/src/extern/glknew/perl/root/},
                   );

    sub static_file {
        my ($self, $file, $type) = @_;
        open my $fh, '<', catfile($self->config->{file_dir}, "$file") or return [ 404, [ 'Content-type', 'text/html' ], [ 'file not found']];

        local $/ = undef;
        my $file_content = <$fh>;
        close $fh or return [ 500, [ 'Content-type', 'text/html' ], [ 'Internal Server Error'] ];

        return [ 200, [ 'Content-type' => $type ], [ $file_content ] ];
 
    }

    sub new_game {
        my ($self, $game_path) = @_;
        my $gameid = scalar @games;
        # $games[$gameid] = Game->new('/usr/src/extern/glknew/perl/t/var/Advent.ulx');
        my $game = Game->new($game_path);
        $game->user_info($gameid);
        $games[$gameid] = $game;

        $game->wait_for_select;

        return $game;
    }

    dispatch {
        sub (/) {
            return $self->static_file("index.html");
        },

        sub (/game/continue/* + %text~&char~) {
          my ($self, $gameid, $text, $char) = @_;

          my $game = $games[$gameid];
          if (defined $text and not defined $char) {
            $game->send_to_game("evtype_LineInput $text\n");
          } elsif (not defined $text and defined $char) {
            $game->send_to_game("evtype_CharInput ".ord($char)."\n");
          } elsif (not defined $text and not defined $char) {
            # The user hit alt-d ret ?
            $game->send_to_game("evtype_None\n");
          } else {
            # Both text and char are defined?
            die "Double-down on continue -- char='$char', text='$text'";
          }

          $game->wait_for_select;

          my $form = get_form($game);

          [ 200, 
            [ 'Content-type' => 'text/html' ], 
            [ get_formatted_text($game->root_window) . $form ]
          ];

        },

        sub (/game/new/*) {
            my ($self, $game_name) = @_;

            my %games = (
                         advent => './t/var/Advent.ulx',
                         'blue-lacuna' => '/mnt/shared/projects/games/flash-if/blue-lacuna/BlueLacuna-r3.gblorb',
                         # FIXME: Why does the gblorb not work?
                         alabaster => '/mnt/shared/projects/games/flash-if/Alabaster/exec.glul',
                         acg => '/mnt/shared/projects/games/flash-if/ACG/ACG.ulx',
                         king => '/mnt/shared/projects/games/flash-if/king/exec.glul',
                        );
            my $game_path = $games{$game_name};

            if (!$game_path) {
              die "Do not know game path for game $game_name -- supported: ".join(", ", keys %games);
            }

            my $game = $self->new_game($game_path);
            my $form = get_form($game);

            [ 200, 
              [ 'Content-type' => 'text/html' ], 
              [ get_initial_windows($game) . $form ]
            ];
          }
      };

    sub get_form {
      my ($game) = @_;

      my $gameid = $game->user_info;
      my $form;
      {
        no warnings 'uninitialized';
        if ($game->{current_select}{input_type} eq 'line') {
          $form = "<form method='post' action='/game/continue/$gameid'><input type='text' name='text' /></form>";
        } elsif ($game->{current_select}{input_type} eq 'char') {
          $form = "<form method='post' action='/game/continue/$gameid'><i>want char</i><input type='text' name='char' /></form>";
        } elsif (not defined $game->{current_select}{input_type}) {
          die "Don't know how to handle this callback -- \$game->{current_select}{input_type} not defined";
        } else {
          print STDERR Dumper($game->{current_select});
          die "Don't know how to handle this callback -- \$game->{current_select}{input_type} eq \'$game->{current_select}{input_type}\'";
        }
      }

      return $form;
    }

    sub get_initial_windows {
        my ($game) = @_;

        return get_formatted_text($game->root_window);
    }

    ## get_window_layout?
    ## IN Window object
    ## OUT Laid out window text plus all child windows
    sub get_formatted_text {
      my ($win) = @_;

      my $own_text = get_own_formatted_text($win);

      for my $child (@{$win->{children}}) {
        $own_text = layout_child_window($child, $own_text);
      }

      return $own_text;
    }


    ## IN: Child window, Parents text so-far
    ## OUT: New text containing parent + child text
    sub layout_child_window {
        my ($child, $parent_text) = @_;

        my $child_text = get_formatted_text($child);
        warn Dumper($child->{method});

        my ($side, $kind, $axis);
        for my $method (@{$child->{method}}) {
          if ($method ~~ [qw<above below>]) {
            $axis = 'y';
            $side = $method;
          } elsif ($method ~~ [qw<left right>]) {
            $axis = 'x';
            $side = $method;
          } elsif ($method ~~ [qw<fixed proportional>]) {
            $kind = $method;
          } else {
            die "Unhandled method $method";
          }
        }

        if ($side eq 'above' and $kind eq 'fixed' and $axis eq 'y') {
          $parent_text = <<END;
<table>
 <tr><td>$child_text</td></tr>
 <tr><td>$parent_text</td></tr>
</table>
END
        } elsif ($side eq 'left' and $kind eq 'proportional' and $axis eq 'x') {
          $parent_text = <<END;
<table>
 <tr><td width="$child->{size}%">$child_text</td><td>$parent_text</td></tr>
</table>
END
        } else {
          die "Unhandled situation, side=$side, kind=$kind, axis=$axis";
        }

        return $parent_text;
    }

    # FIXME: How much of this belongs in Game.pm?
    sub get_own_formatted_text_grid {
      my ($win) = @_;

      my ($cursor) = [0, 0];
      my $state;

      my $style = undef;
      for my $e (@{$win->{content}}) {
        if (exists $e->{cursor_to}) {
          $cursor = [$e->{cursor_to}[1], $e->{cursor_to}[0]];
        } elsif (exists $e->{char}) {
          # always char and style.
          $state->[$cursor->[0]][$cursor->[1]]{char}  = $e->{char};
          $state->[$cursor->[0]][$cursor->[1]]{style} = $e->{style};
          $cursor->[1]++;
        } else {
          die Dumper($e);
        }
      }

      my $text = "<tt>";
      my %styles_needed;
      for my $line (@$state) {
        for my $new_e (@$line) {
          if (!$new_e) {
            $text .= '&nbsp;';
            next;
          }

          if ($new_e->{char} eq '<') {
            $text .= '&lt;';
          } elsif ($new_e->{char} eq '&') {
            $text .= '&amp;';
          } elsif ($new_e->{char} eq ' ') {
            $text .= '&nbsp;';
          } else {
            $text .= $new_e->{char};
          }
        }
        $text .= "<br />\n";
      }
      $text .= "</tt>\n";

      return "<div id='winid$win->{id}'>$text</div>"
    }

    # FIXME: Split this properly by wintype?  Make them objects, of different classes?
    sub get_own_formatted_text {
      my ($win) = @_;

      if (!ref $win) {
        $win = $self->{windows}{$win};
        return '' if(!$win);
      }

      if ($win->{wintype} eq 'TextGrid') {
        return get_own_formatted_text_grid($win);
      }

      my $text = '';
      my $prev_style = {};

      my %styles_needed;

      for my $e (@{$win->{content}}) {
        my ($style, $char) = @{$e}{'style', 'char'};
        if(defined $style) {
          if ($prev_style != $style) {
            if(%$prev_style) {
              $text .= '</span>';
            }
            $text .="<span class='winid$win->{id}-$style->{name}'>";
            $styles_needed{"winid$win->{id}-$style->{name}"} = $style;
          }
          if ($char eq '<') {
            $text .= '&lt;';
          } elsif ($char eq "\n") {
            $text .= "<br />\n";
          } else {
            $text .= $char;
          }

          $prev_style = $style;
        } elsif(exists $e->{cursor_to}) {
          warn "Cursor to: ", join(':', @{ $e->{cursor_to} }), "\n";
        }
      }
      ## newline so status window line is seen..
      #    print "\n";

      my $styles = '';
      for my $name (sort keys %styles_needed) {
        # Copy so we can freely modify it here.
        my $style = { %{$styles_needed{$name}} };

        warn Dumper($style);
        $styles .= ".$name {";

        delete $style->{name};
        if (exists $style->{TextColor}) {
          $styles .= sprintf " color: #%06x; ", delete($style->{TextColor});
        }
        if (exists $style->{Weight}) {
          my $weight = {
                        -1 => '100',
                         0 => '400',
                         1 => '700'}->{$style->{Weight}};
          if ($weight) {
            $styles .= " font-weight: $weight; ";
            delete $style->{Weight};
          }
        }
        if (exists $style->{Proportional}) {
          if (!$style->{Proportional}) {
            $styles .= " font-family: monospace; ";
            delete $style->{Proportional};
          }
        }
        if (exists $style->{Size}) {
          my $size = {
                       0 => 'medium'
                      }->{$style->{Size}};
          if ($size) {
            $styles .= " font-size: $size; ";
            delete $style->{Size};
          }
        }
        if (exists $style->{Oblique}) {
          if ($style->{Oblique}) {
            $styles .= " font-style: oblique; ";
            delete $style->{Oblique};
          } else {
            $styles .= " font-style: normal; ";
            delete $style->{Oblique};
          }
        }


        for my $k (sort keys %$style) {
          warn "Unhandled style hint $k (val=$style->{$k})";
        }

        $styles .= "}\n";
      }
      $text = "<style type='text/css'>$styles</style>\n$text";

      return "<div id='winid$win->{id}'>$text</div>";
    }

}

GameIF->run_if_script;
