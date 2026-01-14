package com.example.web;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class WebApplicationTest {

    @Test
    void testGetModuleName() {
        WebApplication app = new WebApplication();
        assertEquals("web", app.getModuleName());
    }
}
