#!/usr/bin/env perl

use strict;
use warnings;

use File::Which;
use English qw(-no_match_vars);
use Data::Dumper;

use Test::More;
use File::Temp qw(tempfile);
use File::Spec;
use JSON qw(to_json);
use Config::Resolver;
use Config::Resolver::Utils qw(slurp_file);
use Config::Resolver::Plugin::SSM;

my $ssm_plugin = Config::Resolver::Plugin::SSM->new( endpoint_url => $ENV{TEST_SSM} );

########################################################################
sub put_parameter {
########################################################################
  my ( $path, $secret_val ) = @_;

  $ssm_plugin->put_ssm_parameter( $path, $secret_val, 1 );

  my $parameter = $ssm_plugin->get_ssm_parameter( $path, 1 );

  return $parameter;
}

# --- Find our script and lib paths ---
my $Script = which 'config-resolver.pl';
my $Perl   = $EXECUTABLE_NAME;

# --- Test 1: Full end-to-end plugin run ---
########################################################################
subtest 'Test Case: End-to-end --plugin ssm flag' => sub {
########################################################################

  SKIP: {
    skip 'Skipping: Set TEST_SSM=http://localhost:4566 to run live LocalStack tests', 3
      if !$ENV{TEST_SSM};

    # 1. --- Prime LocalStack with a real secret ---
    my $secret_path = 't/99/my-secret';
    my $secret_val  = 'B-U-T-FULL!';

    $secret_val = put_parameter( $secret_path, $secret_val );
    is( $secret_val, 'B-U-T-FULL!' );

    # 2. --- Setup the "battlefield" ---

    # Create params.json that points to our new secret
    my ( $p_fh, $p_path ) = tempfile( SUFFIX => '.json', UNLINK => 1 );
    print ${p_fh} to_json( { my_secret => "ssm://$secret_path" } );
    close $p_fh;

    # Create the template
    my ( $t_fh, $t_path ) = tempfile( SUFFIX => '.tpl', UNLINK => 1 );
    print ${t_fh} 'The secret value is: ${my_secret}';
    close $t_fh;

    # 3. --- Execute the real script ---
    my $command
      = "$Perl $Script resolve " . "-p $p_path -t $t_path --plugins SSM " . "--plugin ssm:endpoint_url=$ENV{TEST_SSM}";

    my $script_output = qx($command 2>&1);

    # 4. --- Verify the results ---

    # Check 2: Did the script exit successfully?
    is( $?, 0, 'Script exited successfully (exit code 0)' )
      or diag("Script Output: $script_output");

    # Check 3: The FINAL proof. Is the content correct?
    is( $script_output, "The secret value is: $secret_val", 'Output string is correctly rendered from SSM' );
  }
};

done_testing();

1;
