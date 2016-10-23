package edu.utexas.ece.moez.smallMaven;

import static org.junit.Assert.*;
import org.junit.Test;

public class AppTest
{
	@Test
	public void testAdd1()
	{
		int a=3, b=4, expected=a+b, actual;
		actual = App.add1(a,b);
		assertEquals(expected, actual);
	}

	@Test
	public void testAdd2()
	{
		int a=-1, b=1, expected=a+b, actual;
		actual = App.add2(a,b);
		assertEquals(expected, actual);
	}

	@Test
	public void testAdd3()
	{
		int a=3, b=-4, expected=a+b, actual;
		actual = App.add3(a,b);
		assertEquals(expected, actual);
	}
}
