import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

import org.junit.Test;
import static org.junit.Assert.*;

import com.example.javamavenjunithelloworld.Code;

public class TestCode 
{
	@Test
	public void checkResponseCode()
	{
		assertEquals(200, Code.getResponseCode());
	}
}
