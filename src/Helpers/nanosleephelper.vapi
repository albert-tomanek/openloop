class NanoSleepHelper
{
	[CCode (cname = "vala_nanosleep")]
	public static void sleep(uint64 sec, uint64 nsec);
}
