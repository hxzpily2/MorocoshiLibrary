package net.morocoshi.moja3d.atlas 
{
	import net.morocoshi.common.timers.Stopwatch;
	import net.morocoshi.moja3d.moja3d;
	
	use namespace moja3d;
	
	/**
	 * ...
	 * 
	 * @author tencho
	 */
	public class TextureAtlasController 
	{
		static moja3d const FRAME:int = 0;
		static moja3d const ANIMATE_FPS:int = 1;
		static moja3d const ANIMATE_FRAME:int = 2;
		
		moja3d var type:int = ANIMATE_FPS;
		moja3d var fps:Number = 30;
		moja3d var frame:int = 0;
		moja3d var loop:int = 0;
		moja3d var timer:Stopwatch;
		
		public function TextureAtlasController() 
		{
			timer = new Stopwatch();
		}
		
		public function setFrame(frame:int):void
		{
			type = FRAME;
			this.frame = frame;
		}
		
		public function setAnimateFPS(fps:Number):void
		{
			type = ANIMATE_FPS;
			this.fps = fps;
		}
		
		public function setAnimateFrame():void
		{
			type = ANIMATE_FRAME;
		}
		
		public function get isPlaying():Boolean
		{
			return timer.isPlaying;
		}
		
		public function play(loop:int = 0):void
		{
			timer.reset();
			timer.start();
			this.loop = loop;
		}
		
		public function stop():void
		{
			timer.stop();
		}
		
		public function resume():void
		{
			timer.start();
		}
		
		public function setTime(time:Number):void
		{
			timer.time = time;
		}
		
		public function getFrame():int 
		{
			switch(type)
			{
				case FRAME: return frame;
				case ANIMATE_FPS: return timer.time / 1000 * fps;
				case ANIMATE_FRAME: return frame++;
			}
			return 0;
		}
		
	}

}