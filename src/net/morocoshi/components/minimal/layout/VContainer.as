package net.morocoshi.components.minimal.layout 
{
	import com.bit101.components.VBox;
	import flash.display.DisplayObjectContainer;
	
	/**
	 * ...
	 * @author tencho
	 */
	public class VContainer extends VBox 
	{
		
		public function VContainer(parent:DisplayObjectContainer = null, xpos:Number = 0, ypos:Number = 0, list:Array = null, spacing:Number = 0)
		{
			super(parent, xpos, ypos);
			this.spacing = spacing;
			if (!list)
			{
				for (var i:int = 0; i < list.length; i++) 
				{
					addChild(list[i]);
				}
				updateSize();
			}
		}
		
		public function updateSize():void
		{
			spacing = spacing;
		}
		
	}

}