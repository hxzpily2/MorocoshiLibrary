package net.morocoshi.moja3d.particle 
{
	/**
	 * ...
	 * @author tencho
	 */
	public class ParticleTextureAtlas 
	{
		static public const FRAME:int = 0;
		static public const RANDOM_ALL:int = 1;
		static public const RANDOM_FRAMES:int = 2;
		static public const ANIMATE_ALL:int = 3;
		static public const ANIMATE_FRAMES:int = 4;
		
		public var type:int = RANDOM_ALL;
		public var frame:int;
		public var frames:Array;
		
		public function ParticleTextureAtlas() 
		{
			frame = 0;
			frames = [0];
		}
		
		public function setFrame(frame:int):void
		{
			type = FRAME;
			this.frame = frame;
		}
		
		public function setAnimateAll():void
		{
			type = ANIMATE_ALL;
		}
		
		public function setRandomAll():void
		{
			type = RANDOM_ALL;
		}
		
		public function setRandomFrames(frames:Array):void
		{
			type = RANDOM_FRAMES;
			this.frames = frames.concat();
		}
		
		public function setAnimateFrames(frames:Array):void
		{
			type = ANIMATE_FRAMES;
			this.frames = frames.concat();
		}
		
		public function clone():ParticleTextureAtlas 
		{
			var result:ParticleTextureAtlas = new ParticleTextureAtlas();
			result.type = type;
			result.frame = frame;
			result.frames = frames.concat();
			return result;
		}
		
	}

}