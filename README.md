# Exhibitor in OpenShift

## Why a specific OpenShift image?

OpenShift has specific requirements for Docker images that makes them a little more difficult to run in the cluster.  This Dockerfile resolves those requirements and is capable of running in OpenShift

## Running

Follow the [Exhibitor configuration guide](https://github.com/soabase/exhibitor/wiki/Running-Exhibitor) to build the proper configuration to run Exhibitor.  Here is an example using S3

```bash
docker run --rm -p 2181:2181 -p 2888:2888 -p 3888:3888 -p 8080:8080 deciphernow/exhibitor:1.6.0-3.4.13 /exhibitor-wrapper -c s3 --s3region us-east-1 --s3credentials /path/to/credentials/on/disk --s3config my-s3-exhibitor-bucket/my-cool-exhibitor --hostname server-ip-address
```

## Building

To build a new image from this repository:

        ./build.sh

This will build and tag the version of Exhibitor defined in the [EXHIBITOR_VERSION](EXHIBITOR_VERSION) file. Alternatively, you can build a specific version of Exhibitor and Zookeper by providing the version numbers (Exhibitor first, then Zookeeper):

        ./build.sh 1.7.1 3.4.13

## Publishing

To publish the image built by this repository:

        ./publish.sh

This will publish the tags corresponding to the version defined in the [VERSION](VERSION) file. Alternatively, you can publish a specific tags by providing the version numbers (Exhibitor first, then Zookeeper):

        ./publish.sh 1.7.1 3.4.13

## Contributing

1. Fork it
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Commit your changes (`git commit -am 'Add some feature'`)
1. Push to the branch (`git push origin my-new-feature`)
1. Create new Pull Request