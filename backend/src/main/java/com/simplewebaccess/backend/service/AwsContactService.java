package com.simplewebaccess.backend.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.simplewebaccess.backend.dto.ContactRequest;
import com.simplewebaccess.backend.model.Contact;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.core.ResponseInputStream;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectResponse;
import software.amazon.awssdk.services.s3.model.ListObjectsV2Request;
import software.amazon.awssdk.services.s3.model.S3Object;
import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.model.SendMessageRequest;

import java.util.ArrayList;
import java.util.List;

@Service
@Profile("prod")
@RequiredArgsConstructor
public class AwsContactService implements ContactService {

    private final SqsClient sqsClient;
    private final S3Client s3Client;
    private final ObjectMapper objectMapper;

    @Value("${aws.sqs.queue-url}")
    private String queueUrl;

    @Value("${aws.s3.bucket}")
    private String bucket;

    @Override
    public void save(ContactRequest request) {
        try {
            String body = objectMapper.writeValueAsString(request);
            sqsClient.sendMessage(SendMessageRequest.builder()
                .queueUrl(queueUrl)
                .messageBody(body)
                .build());
        } catch (Exception e) {
            throw new RuntimeException("Failed to serialize contact request", e);
        }
    }

    @Override
    public List<Contact> findAll() {
        List<Contact> contacts = new ArrayList<>();

        var objects = s3Client.listObjectsV2(ListObjectsV2Request.builder()
            .bucket(bucket)
            .prefix("contacts/")
            .build());

        for (S3Object obj : objects.contents()) {
            try (ResponseInputStream<GetObjectResponse> stream = s3Client.getObject(
                    GetObjectRequest.builder().bucket(bucket).key(obj.key()).build())) {
                contacts.add(objectMapper.readValue(stream, Contact.class));
            } catch (Exception e) {
                // skip malformed objects
            }
        }

        return contacts;
    }
}
