package com.example.service;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class ServiceApplicationTest {

    @Test
    void testGetModuleName() {
        ServiceApplication app = new ServiceApplication();
        assertEquals("service", app.getModuleName());
    }
}
