package com.simplewebaccess.backend.service;

import com.simplewebaccess.backend.dto.ContactRequest;
import com.simplewebaccess.backend.model.Contact;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@Profile("local")
public class InMemoryContactService implements ContactService {

    private final List<Contact> store = new ArrayList<>();

    @Override
    public void save(ContactRequest request) {
        store.add(new Contact(
                request.getName(),
                request.getEmail(),
                request.getMessage()));
    }

    @Override
    public List<Contact> findAll() {
        return List.copyOf(store);
    }
}
