package edu.utexas.ece.moez.smallMaven;

import static org.junit.Assert.*;
import org.junit.Test;

public class AppTest
{
	@Test
	public void testAdd()
	{
		int a=3, b=4, expected=a+b, actual;
		actual = App.addOf(a,b);
		assertEquals(expected, actual);
	}

	@Test
	public void concateTest()
	{
		String suffix="Dr. ", prefix="Xivago", expected=suffix+prefix, actual;
		actual = App.concatenate(suffix, prefix);
		assertEquals(expected, actual);
	}

	@Test
	public void testGreeting()
	{
		assertEquals(App.HELLO, App.greetingMessage());
	}
}
