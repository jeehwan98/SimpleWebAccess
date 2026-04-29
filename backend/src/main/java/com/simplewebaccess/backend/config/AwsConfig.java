package com.simplewebaccess.backend.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.S3ClientBuilder;
import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.SqsClientBuilder;

import java.net.URI;

@Configuration
@Profile("prod")
public class AwsConfig {

    @Value("${aws.endpoint:}")
    private String awsEndpoint;

    @Bean
    public SqsClient sqsClient() {
        SqsClientBuilder builder = SqsClient.builder()
            .region(Region.AP_SOUTHEAST_1);

        if (!awsEndpoint.isBlank()) {
            builder.endpointOverride(URI.create(awsEndpoint))
                   .credentialsProvider(StaticCredentialsProvider.create(
                       AwsBasicCredentials.create("test", "test")));
        }

        return builder.build();
    }

    @Bean
    public S3Client s3Client() {
        S3ClientBuilder builder = S3Client.builder()
            .region(Region.AP_SOUTHEAST_1);

        if (!awsEndpoint.isBlank()) {
            builder.endpointOverride(URI.create(awsEndpoint))
                   .credentialsProvider(StaticCredentialsProvider.create(
                       AwsBasicCredentials.create("test", "test")))
                   .forcePathStyle(true);
        }

        return builder.build();
    }
}
