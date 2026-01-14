package com.example.api;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class ApiApplicationTest {

    @Test
    void testGetModuleName() {
        ApiApplication app = new ApiApplication();
        assertEquals("api", app.getModuleName());
    }
}
