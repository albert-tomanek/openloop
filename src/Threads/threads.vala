class OpenLoop.AppThreads
{
	public bool running;

	public Threads.LoopImporter loop_importer = new Threads.LoopImporter();

	public void start()
	{
		this.running = true;

		this.loop_importer.thread = new Thread<void *>.try(null, loop_importer.run);
	}

	public void stop()
	{
		this.running = false;
	}
}
