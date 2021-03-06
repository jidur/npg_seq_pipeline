use strict;
use warnings;
use Test::More tests => 14;
use Test::Exception;
use File::Path qw(make_path);
use t::util;

my $util = t::util->new();
my $tmp_dir = $util->temp_directory();

use_ok('npg_pipeline::run::folder::link');

my $runfolder_path = $util->analysis_runfolder_path();
my $link_to = 'Data/Intensities/BAM_basecalls_20150608-091427/no_cal';
my $recalibrated_path = join q[/], $runfolder_path, $link_to;
make_path($recalibrated_path);

{
  my $rfl;
  my $link = "$runfolder_path/Latest_Summary";
  ok(!-e $link, 'link does not exist - test prerequisite');
  lives_ok {
    $rfl = npg_pipeline::run::folder::link->new(
      run_folder        => q{123456_IL2_1234},
      runfolder_path    => $runfolder_path,
      recalibrated_path => $recalibrated_path,
    );
  } q{no croak with all attributes provided };
  lives_ok { $rfl->make_link(); } q{no croak creating link};
  ok(-l $link, 'link exists');
  is(readlink $link, $link_to, 'correct link target');
  lives_ok { $rfl->make_link(); } q{no croak creating link when it already exists};
  ok(-l $link, 'link exists');

  rename "$tmp_dir/nfs/sf45/IL2/analysis", "$tmp_dir/nfs/sf45/IL2/outgoing";
  $link              =~ s/analysis/outgoing/;
  $runfolder_path    =~ s/analysis/outgoing/;
  $recalibrated_path =~ s/analysis/outgoing/;

  $rfl = npg_pipeline::run::folder::link->new(
    run_folder        => q{123456_IL2_1234},
    runfolder_path    => $runfolder_path,
    recalibrated_path => $recalibrated_path,
  );
  lives_ok { $rfl->make_link();} q{no croak creating link in outgoing when it already exists};
  ok(-l $link, 'link exists');
  unlink $link;
  ok(!-e $link, 'link deleted - test prerequisite');
  lives_ok { $rfl->make_link(); } q{no croak creating link in outgoing};
  ok(-l $link, 'link exists');
  is(readlink $link, $link_to, 'correct link target');
}

1;
