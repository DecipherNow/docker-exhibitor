# Exhibitor in OpenShift

## Why a specific OpenShift image?

OpenShift has specific requirements for Docker images that makes them a little more difficult to run in the cluster.  This Dockerfile resolves those requirements and is capable of running in OpenShift

## Required Environment Variables

The below table shows the required environment variables needed to run Exhibitor.  In OpenShift, these should be set in the Exhibitor Template file.

| Variable | Default Value | Description |
| :------ |:-------------| :----------|
| BUCKET |  |  The S3 bucket that Exhibitor has access to use for shared configs |
| PREFIX | development | This is the S3 filename that exhibitor will use |
| REGION | us-east-1 | The AWS region where the bucket is created |
| PORT0 | 8080 | The port that will be exposed for the Exhibitor UI |
| PORT1 | 2181 | The ZK Client Port |
| PORT2 | 2888 | The ZK server Port |
| PORT3 | 3888 | The ZK election Port |
| SECRETS_PATH | /opt/exhibitor-secrets | This is the path where OpenShift will put the AWS secrets |
| SECRETS_FILE | exhibitor | This is the filename where OpenShift will store the secrets. (This is the value of the key for the secrets stored in OpenShift) |
| IP_ADDR | localhost | This should be set to the IP of the host or POD where zookeeper will be run |

### Exhibitor Secrets

This version of Exhibitor specifically runs with the S3 backend for sharing content across nodes.  The AWS credentials stored in `${SECRETS_FILE}` should allow the following IAM actions for a User or Instance Role: 

    "s3:AbortMultipartUpload",
    "s3:GetBucketAcl",
    "s3:GetBucketPolicy",
    "s3:DeleteObject",
    "s3:GetObject",
    "s3:GetObjectAcl",
    "s3:ListBucket",
    "s3:ListBucketMultipartUploads",
    "s3:ListMultipartUploadParts",
    "s3:PutObject",
    "s3:PutObjectAcl"

The `${SECRETS_FILE}` itself is a java properties file and requires the following contents

``` bash 
com.netflix.exhibitor.s3.access-key-id=<AWS_ACCESS_KEY_ID>
com.netflix.exhibitor.s3.access-secret-key=<AWS_SECRET_KEY>
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