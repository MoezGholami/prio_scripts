package edu.utexas.ece.moez.smallMaven;

/**
 * Hello world!
 *
 */
public class App 
{

	public static final String HELLO = "hello!";

	public static void main(String[] args )
    {
        System.out.println( "Hello World!" );
    }

    public static int addOf(int a, int b)
	{
		return a+b;
	}

	public static String concatenate(String a, String b)
	{
		return a+b;
	}

	public static String greetingMessage()
	{
		return HELLO;
	}
}
