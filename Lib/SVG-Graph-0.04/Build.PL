
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "File::Find" => 0,
    "File::Temp" => 0,
    "Module::Build" => "0.3601",
    "Test::More" => 0,
    "warnings" => 0
  },
  "configure_requires" => {
    "Module::Build" => "0.3601"
  },
  "dist_abstract" => "Visualize your data in Scalable Vector Graphics (SVG) format.",
  "dist_author" => [
    "Chris Fields <cjfields\@bioperl.org>"
  ],
  "dist_name" => "SVG-Graph",
  "dist_version" => "0.04",
  "license" => "artistic_2",
  "module_name" => "SVG::Graph",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Data::Dumper" => 0,
    "Math::Derivative" => 0,
    "Math::Spline" => 0,
    "SVG" => 0,
    "Statistics::Descriptive" => 0,
    "Tree::DAG_Node" => 0,
    "base" => 0,
    "constant" => 0,
    "strict" => 0
  },
  "script_files" => []
);


my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
