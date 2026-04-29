package com.simplewebaccess.backend.service;

import com.simplewebaccess.backend.dto.ContactRequest;
import com.simplewebaccess.backend.model.Contact;

import java.util.List;

public interface ContactService {
    void save(ContactRequest request);
    List<Contact> findAll();
}
