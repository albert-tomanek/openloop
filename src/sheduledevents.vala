/* This is a mechanism that is used to store an event so that it can happen at a later time.
 * For example, it can be used to schedule for a tile to start playing at the next bar.
 */

namespace OpenLoop.ScheduledEvents
{
	abstract class Event : Object
	{
		public abstract void execute();
	}

	/* Tile events */
	abstract class TileEvent : Event
	{
		public Tile tile;

		public TileEvent(Tile tile)
		{
			this.tile = tile;
		}
	}

	class TileStartEvent : TileEvent
	{
		public TileStartEvent(Tile tile)
		{
			base(tile);
		}

		public override void execute()
		{
			this.tile.start();
		}
	}

	class TileStopEvent : TileEvent
	{
		public TileStopEvent(Tile tile)
		{
			base(tile);
		}

		public override void execute()
		{
			this.tile.stop();
		}
	}
}
