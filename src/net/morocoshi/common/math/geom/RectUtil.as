package net.morocoshi.common.math.geom 
{
	import flash.geom.Rectangle;
	
	/**
	 * 矩形処理
	 * 
	 * @author	tencho
	 */
	public class RectUtil 
	{
		/**
		 * 対象の矩形を枠に合わせてリサイズした時の新しい矩形を返す
		 * 
		 * @param	target	リサイズしたい矩形
		 * @param	frame	合わせる枠
		 * @param	mode	リサイズタイプ
		 * @param	xper	X軸の配置
		 * @param	yper	Y軸の配置
		 * @return
		 */
		static public function adjust(target:Rectangle, frame:Rectangle, mode:String = "auto", xper:Number = 0.5, yper:Number = 0.5):Rectangle
		{
			var aspF:Number = frame.width / frame.height;
			var aspT:Number = target.width / target.height;
			
			var w:Boolean = aspF < aspT;
			var sh:Boolean = target.height < frame.height;
			var resize:Rectangle = new Rectangle();
			
			switch(mode)
			{
				case ScaleMode.FIT:
					resize = frame.clone();
					break;
				case ScaleMode.NONE:
					resize = target.clone();
					break;
			}
			if ((w && (mode == ScaleMode.AUTO || mode == ScaleMode.AUTO_SMALL)) || (mode == ScaleMode.FULL && !w))
			{
				resize.width = (mode == ScaleMode.AUTO_SMALL && target.width < frame.width)? target.width : frame.width;
				resize.height = resize.width / aspT;
			}
			else if (mode != ScaleMode.NONE)
			{
				resize.height = (mode == ScaleMode.AUTO_SMALL && target.height < frame.height)? target.height : frame.height;
				resize.width = resize.height * aspT;
			}
			
			resize.x = frame.x + (frame.width - resize.width) * xper;
			resize.y = frame.y + (frame.height - resize.height) * yper;
			return resize;
		}
		
	}

}