# Easy nginx proxy

This container provides a dead-simple way to proxy services as subdomains.

## Configuration

Just add a file named `config.cfg` with each line formatted as:

	[subdomain] [backend address]

For example:
	
	cups http://example.com:631

Will proxy `cups.example.com` to the cups server on `example.com` port `631`.

## Usage

	run.sh [domain] [email address]

The domain could be an IP address, but must be a valid domain name if you want to use HTTPS. If this is for a local server, use https://github.com/dave-burke/docker-dns to configure local DNS using the `andyshinn/dnsmasq` image.

The email address is optional, but if one is provided then the container will attempt to configure HTTP using letsencrypt.

