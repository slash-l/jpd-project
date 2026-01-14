package com.example.core;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class CoreApplicationTest {

    @Test
    void testGetModuleName() {
        CoreApplication app = new CoreApplication();
        assertEquals("core", app.getModuleName());
    }
}
