import org.junit.Test;
import static org.junit.Assert.*;

public class Tester
{
	@Test
	public void validateGreetingMessage()
	{
		UnderTest uut = new UnderTest();
		String expected="Hello World!", actual=uut.greetingMessage();
		assertEquals(expected, actual);
	}
}
