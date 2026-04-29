package com.simplewebaccess.backend.controller;

import com.simplewebaccess.backend.dto.ContactRequest;
import com.simplewebaccess.backend.model.Contact;
import com.simplewebaccess.backend.service.ContactService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class ContactController {

    private final ContactService contactService;

    /** -> AwsContactService.findAll() -> S3 */
    @GetMapping("/contacts")
    public ResponseEntity<List<Contact>> getContacts() {
        return ResponseEntity.ok(contactService.findAll());
    }

    /***
     * -> AwsContactService.save() -> SQS (message queue) -> Lambda -> save contact
     * in S3
     */
    @PostMapping("/contacts")
    public ResponseEntity<String> saveContact(@RequestBody ContactRequest request) {
        contactService.save(request);
        return ResponseEntity.ok("Message received");
    }
}
