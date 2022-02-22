package com.bugsnag.flutter;

import com.bugsnag.android.ErrorType;
import com.bugsnag.android.Stackframe;

import junit.framework.TestCase;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;

import java.nio.ByteBuffer;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;

@RunWith(Parameterized.class)
public class StackframeCodecTest extends TestCase {

    private final StackframeCodec codec = new StackframeCodec();

    private final ErrorType errorType;

    public StackframeCodecTest(ErrorType errorType) {
        this.errorType = errorType;
    }

    @Test
    public void androidFrame() {
        Stackframe stackframe = new Stackframe(
                "theErrorMethod",
                "SomeFile.java",
                1234,
                true
        );

        testTranscode(stackframe);
    }

    private void testTranscode(Stackframe stackframe) {
        DataWriter writer = new DataWriter(Collections.singletonList(codec));
        writer.putObject(stackframe);

        ByteBuffer encoded = writer.done();
        encoded.limit(encoded.position());
        encoded.rewind(); // rewind the ByteBuffer so we can read it

        DataReader reader = new DataReader(encoded, Collections.singletonList(codec));
        Stackframe decoded = reader.getObject();

        assertEquals(stackframe, decoded);
    }

    private void assertEquals(Stackframe expected, Stackframe actual) {
        assertEquals(expected.getMethod(), actual.getMethod());
        assertEquals(expected.getFile(), actual.getFile());
        assertEquals(expected.getLineNumber(), actual.getLineNumber());
        assertEquals(expected.getInProject(), actual.getInProject());
        assertEquals(expected.getCode(), actual.getCode());
        assertEquals(expected.getColumnNumber(), actual.getColumnNumber());
        assertEquals(expected.getFrameAddress(), actual.getFrameAddress());
        assertEquals(expected.getSymbolAddress(), actual.getSymbolAddress());
        assertEquals(expected.isPC(), actual.isPC());
        assertEquals(expected.getType(), actual.getType());
    }

    @Parameterized.Parameters
    public static Collection<ErrorType> createParameters() {
        return Arrays.asList(ErrorType.values());
    }

}
