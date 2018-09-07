class OpenLoop.Threads.LoopImporter
{
	public Thread<void *> thread;
	public Gee.ArrayQueue<GUI.LoopSourceItem> queue = new Gee.ArrayQueue<GUI.LoopSourceItem>();

	public LoopImporter()
	{
	}

	public void *run()
	{
		while (App.threads.running)
		{
			while (!this.queue.is_empty)
			{
				var item = this.queue.poll();

				item.loop = Loop.import_path(item.file_path);
				item.load_finished();
			}

			Thread.usleep(500 * 1000);	// 500ms
		}

		return null;
	}
}
