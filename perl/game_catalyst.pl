my $c = {
    name => 'Game::Catalyst',

  # Note that this key is used both as a URI element and a filename element.  For simplicity, keep element names lacking in URI & HTML metacharacters, please.
  # The title, OTOH, can be any arbitrary string.

    games => {
        'tight-spot' => {
           vm     => 'z-code',
           location => 'ats.z8',
           title => 'A Tight Spot',
           link => 'http://ifdb.tads.org/viewgame?id=rsjzz9w60k6o6od4',
           nsfw => 0,
        },
        advent => {
            vm    => 'glulx',
            location => 'Advent.ulx',
            title => 'Adventure!',
            restore => [["line", "restore\n"]],
            link => 'http://en.wikipedia.org/wiki/Adventure_(computer_game)',
            nsfw => 0,
          },
        'blue-lacuna' => {
            vm => 'glulx',
            location => 'blue-lacuna/BlueLacuna-r3.gblorb',
            title => 'Blue Lacuna',
            restore => [["char", "r"]],
            link => 'http://www.lacunastory.com/about.html',
            nsfw => 0,
        },
        alabaster     => {
            vm => 'glulx',
            location => 'Alabaster/Alabaster.gblorb',
            title => 'Alabaster',
            restore => [["line", "yes\n"],
                        ["char", " "],
                        ['char', ' '],
                        ["line", "restore\n"]],
            link => 'http://emshort.home.mindspring.com/Alabaster/index.html',
            nsfw => 0,
        },
        acg           => {
            vm => 'glulx',
            location => 'ACG/ACG.ulx',
            title => 'Adventurer\'s Consumer Guide',
            restore => [["line", "restore\n"]],
            link => 'http://ifdb.tads.org/viewgame?id=snk6qx8hfn3xpm0a',
            nsfw => 0,
        },
        king          => {
            vm => 'glulx',
            location => 'The King of Shreds and Patches.gblorb',
            title => 'The King of Shreds and Patches',
            restore => [["char", "r"]],
            link => 'http://maher.filfre.net/King/',
            nsfw => 0,
        },
        curses        => {
            vm => 'z-code',
            location => 'curses.z5',
            title => 'Curses',
            link => 'http://www.sparkynet.com/spag/c.html#curses',
            nsfw => 0,
            restore => [['char', ' '],
                        ['line', 'restore']]
        },
        zork1         => {
            vm => 'z-code',
            location => 'zork1/DATA/ZORK1.DAT',
            title => 'Zork I',
            link => 'http://en.wikipedia.org/wiki/Zork_I',
            nsfw => 0,
        },
        emy           => {
            vm => 'agt',
            location => 'Emy Discovers Life/DISCOVER',
            title => 'Emy Discovers Life',
            restore => [['char', ' '], ['line', "restore\n"]],
            link => 'http://www.ifwiki.org/index.php/Emy_Discovers_Life',
            nsfw => 1,
        },
        sd3           => {
            vm => 'tads2',
            location => 'sd3/SD3.gam',
            title => 'School Dreams 3: School Dreams Forever',
            restore => [['line', "foo\n"], ["line", "restore\n"]],
            link => 'http://www.ifwiki.org/index.php/School_Dreams_3:_School_Dreams_Forever',
            nsfw => 1,
        },
        earlgrey => {
            vm => 'glulx',
            location => 'earlgrey.ulx',
            title => 'Earl Grey',
            link => 'http://www.ifwiki.org/index.php/Earl_Grey',
            nsfw => 0,
        },
        british_fox => {
            vm => 'taf',
            location => 'british_fox_and_the_celebrity_abductions.taf',
            title => 'British Fox and the Celebrity Abductions',
            link => 'http://www.ifwiki.org/index.php/British_Fox_and_the_Celebrity_Abductions',
            nsfw => 1,
        },
    },

    interpreters => {
        glulx => 'git-1.2.6/git',
        tads2 => 'tads2/glk/newtads',
        agt => 'garglk-read-only/terps/agility/glkagil',
        # 'z-code' => '/mnt/shared/projects/games/flash-if/nitfol-0.5/newnitfol',
        'z-code' => 'garglk-read-only/terps/frotz/frotz',
        taf =>      'garglk-read-only/terps/scare/glkscare'
    },

    game_path => '',
};

for (keys %{$c->{games}}) {
  $c->{games}{$_}{shortname} = $_;
}

return $c;
