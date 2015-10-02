package net.morocoshi.components.minimal.layout 
{
	/**
	 * セルの表示サイズとリサイズタイプを決めるデータ
	 * 
	 * @author tencho
	 */
	public class LayoutData 
	{
		static public const PERCENT:String = "%";
		static public const PIXEL:String = "px";
		static public const AUTO:String = "*";
		
		public var size:Number = 0;
		public var unit:String;
		public var resize:String;
		
		/**
		 * コンストラクタ
		 * 
		 * @param	data	セルのサイズを「120px」「75％」「*」等の文字列で決める。
		 * @param	resize	分割線ドラッグによるリサイズ時に親のセルに対する割合でリサイズする場合は「％」、ピクセル指定の場合は「px」。
		 */
		public function LayoutData(data:String, resize:String = PERCENT) 
		{
			this.resize = resize;
			if (data == "*")
			{
				unit = AUTO;
				return;
			}
			var px:Array = data.match(/^(\d+)(px|PX|)$/);
			if (px != null)
			{
				unit = PIXEL;
				size = Number(px[1]);
				return;
			}
			var per:Array = data.match(/^(\d+)%$/);
			if (per != null)
			{
				unit = PERCENT;
				size = Number(per[1]);
				return;
			}
			unit = AUTO;
		}
		
	}

}