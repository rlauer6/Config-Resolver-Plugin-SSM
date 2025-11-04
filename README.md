# NAME

Config::Resolver::Plugin::SSM - AWS Parameter Store backend for Config::Resolver

# SYNOPSIS

    # In your main application
    use Config::Resolver;
    
    # This plugin is loaded automatically by Config::Resolver
    my $resolver = Config::Resolver->new(
        plugins => [ 'SSM' ],
        
        # Options are passed to the plugin
        endpoint_url => 'http://localstack:4566',
        debug        => 1,
    );

    my $value = $resolver->resolve('ssm://my/parameter/path');

# DESCRIPTION

This module is a plugin for [Config::Resolver](https://metacpan.org/pod/Config%3A%3AResolver). It provides a
backend handler for the `ssm://` protocol, allowing the resolver
to fetch values from the AWS SSM Parameter Store.

It uses [Amazon::API::SSM](https://metacpan.org/pod/Amazon%3A%3AAPI%3A%3ASSM) and [Amazon::Credentials](https://metacpan.org/pod/Amazon%3A%3ACredentials) to handle
the AWS connection.

# CONFIGURATION

This plugin is configured by passing a `plugin_config` hash to the
`Config::Resolver` `new()` constructor. The key for this plugin's
configuration \*must\* be `ssm`, as defined by its `$PROTOCOL`
package variable.

**Example (in your main script):**

    use Config::Resolver;
    my $resolver = Config::Resolver->new(
        plugins       => [ 'SSM' ],
        plugin_config => {
            'ssm' => {
                # ... ssm options below ...
                region       => 'us-east-1',
                endpoint_url => 'http://localhost:4566',
            }
        }
    );

This plugin accepts the following keys in its configuration hash:

- order

    An ARRAY reference that determines the order in which
    [Amazon::Credentials](https://metacpan.org/pod/Amazon%3A%3ACredentials) will look for your AWS credentials \[cite: 905-906\].
    Default: `[qw(env container role file)]`

- credentials (optional)

    An instance of [Amazon::Credentials](https://metacpan.org/pod/Amazon%3A%3ACredentials). If not provided, the constructor
    will create one \[cite: 907-908\].

- debug

    Sets debug mode for this plugin and the underlying AWS clients\[cite: 907, 908\].

- endpoint\_url (optional)

    A custom endpoint URL for the SSM API, primarily used for
    LocalStack testing.

- log\_level (optional)

    Sets the log level for the underlying `Amazon::API::SSM` client.
    Default: `'info'`

- warning\_level

    Sets the warning level for parameter resolution.
    Default: `'error'`

# METHODS

## new( $options\_hash\_ref )

Called by `Config::Resolver`. The constructor creates a new,
\*fully initialized\* plugin object. It receives a hash of
configuration options (see [CONFIGURATION](https://metacpan.org/pod/CONFIGURATION) above).

## resolve( $path, $parameters )

Called by `Config::Resolver`. Resolves the `ssm://` placeholder.
This method will always attempt to decrypt `SecureString` parameters.

## get\_ssm\_parameter( $parameter\_name, $with\_decryption )

Retrieves a parameter from the AWS SSM Parameter Store.

## put\_ssm\_parameter( $parameter\_name, $value, $with\_encryption )

Stores a value to AWS Parameter Store.

# AUTHOR

Rob Lauer - <bigfoot@cpan.org>

# SEE ALSO

[Amazon::API::SSM](https://metacpan.org/pod/Amazon%3A%3AAPI%3A%3ASSM), [Amazon::Credentials](https://metacpan.org/pod/Amazon%3A%3ACredentials), [Config::Resolver](https://metacpan.org/pod/Config%3A%3AResolver)
